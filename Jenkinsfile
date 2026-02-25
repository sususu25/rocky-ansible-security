pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    // 인벤토리 생성 방식
    choice(
      name: 'INVENTORY_MODE',
      choices: ['tf_artifact', 'manual'],
      description: 'tf_artifact: Terraform Job의 tf_output.json 사용 / manual: 수기 입력'
    )

    // Terraform 아티팩트 가져올 때 기준 Job
    string(
      name: 'TERRAFORM_JOB_NAME',
      defaultValue: 'Terraform Job',
      description: 'Terraform 파이프라인 Job 이름 (tf_artifact 모드에서 사용)'
    )

    // 수기 입력 모드용 (manual)
    string(
      name: 'BASTION_HOST',
      defaultValue: '',
      description: 'manual 모드에서 bastion 공인 IP/FQDN (예: 133.x.x.x)'
    )
    text(
      name: 'TARGET_HOSTS',
      defaultValue: '',
      description: 'manual 모드에서 대상 서버 private IP 목록 (줄바꿈 구분)\n예:\n10.0.2.45\n10.0.2.36'
    )

    // 실행 관련
    choice(
      name: 'RUN_MODE',
      choices: ['fix', 'check'],
      description: '현재 브랜치가 조치 스크립트 중심이면 fix 사용 (check는 향후 확장용)'
    )

    string(
      name: 'ANSIBLE_BRANCH',
      defaultValue: 'feature/simple-execution',
      description: '체크아웃할 Ansible 레포 브랜치 (Job 설정 브랜치와 달라도 이 값 우선)'
    )

    string(
      name: 'PLAYBOOK_PATH',
      defaultValue: 'playbooks/security_check.yml',
      description: '실행할 playbook 경로'
    )

    string(
      name: 'SSH_CREDENTIALS_ID',
      defaultValue: 'bastion-ssh-key',
      description: 'Jenkins SSH Username with private key Credential ID'
    )

    string(
      name: 'SSH_USER',
      defaultValue: 'rocky',
      description: '대상/배스천 SSH 사용자'
    )

    booleanParam(
      name: 'DO_PING_TEST',
      defaultValue: true,
      description: '플레이북 실행 전 ansible ping 테스트 수행'
    )
  }

  environment {
    GENERATED_DIR = 'generated'
    COLLECTED_LOGS_DIR = 'collected_logs'
    TF_JSON_PATH = 'generated/tf_output.json'
    RUNTIME_INVENTORY = 'generated/hosts.ini'
  }

  stages {
    stage('Checkout Ansible Repo') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.ANSIBLE_BRANCH}"]],
          userRemoteConfigs: [[url: 'https://github.com/sususu25/rocky-ansible-security.git']]
        ])
      }
    }

    stage('Validate Params') {
      steps {
        script {
          if (params.INVENTORY_MODE == 'manual') {
            if (!params.BASTION_HOST?.trim()) {
              error("manual 모드에서는 BASTION_HOST 필수")
            }
            if (!params.TARGET_HOSTS?.trim()) {
              error("manual 모드에서는 TARGET_HOSTS 필수 (줄바꿈으로 여러 개 입력)")
            }
          }
        }
      }
    }

    stage('Prepare Workspace') {
      steps {
        sh '''
          set -e
          mkdir -p "$GENERATED_DIR"
          mkdir -p "$COLLECTED_LOGS_DIR"
          echo "Workspace prepared"
        '''
      }
    }

    stage('Fetch Terraform Output (tf_artifact mode)') {
      when {
        expression { params.INVENTORY_MODE == 'tf_artifact' }
      }
      steps {
        script {
          // Copy Artifact Plugin 필요
          // lastSuccessful() 대신 현재 Jenkins 심볼에 맞는 lastSuccess() 사용
          step([
            $class: 'CopyArtifact',
            projectName: params.TERRAFORM_JOB_NAME,
            selector: lastSuccess(),
            filter: 'tf_output.json',
            target: env.GENERATED_DIR,
            flatten: true
          ])

          if (!fileExists(env.TF_JSON_PATH)) {
            error("tf_output.json 복사 실패: ${env.TF_JSON_PATH} 파일 없음")
          }
        }
      }
    }

    stage('Generate Runtime Inventory') {
      steps {
        script {
          if (params.INVENTORY_MODE == 'tf_artifact') {
            def tf = readJSON file: env.TF_JSON_PATH

            def bastionHost = tf?.bastion_fip?.value
            def backendMap  = tf?.backend_mgmt_private_ips?.value

            if (!bastionHost) {
              error("tf_output.json에서 bastion_fip.value를 찾지 못함")
            }
            if (!(backendMap instanceof Map) || backendMap.isEmpty()) {
              error("tf_output.json에서 backend_mgmt_private_ips.value를 찾지 못했거나 비어있음")
            }

            def lines = []
            lines << "[rocky_servers]"
            backendMap.each { name, ip ->
              // ProxyJump 사용 (젠킨스 -> bastion -> 대상)
              lines << "${name} ansible_host=${ip} ansible_user=${params.SSH_USER} " +
                      "ansible_ssh_common_args='-o ProxyJump=${params.SSH_USER}@${bastionHost} -o StrictHostKeyChecking=no'"
            }
            lines << ""
            lines << "[rocky_servers:vars]"
            lines << "ansible_become=true"
            lines << "ansible_become_method=sudo"
            lines << "ansible_become_user=root"

            writeFile file: env.RUNTIME_INVENTORY, text: lines.join("\n") + "\n"
          } else {
            // manual 모드
            def bastionHost = params.BASTION_HOST.trim()
            def targets = params.TARGET_HOSTS
              .split("\\r?\\n")
              .collect { it.trim() }
              .findAll { it }

            def lines = []
            lines << "[rocky_servers]"
            targets.eachWithIndex { ip, idx ->
              def name = String.format("rocky%02d", idx + 1)
              lines << "${name} ansible_host=${ip} ansible_user=${params.SSH_USER} " +
                      "ansible_ssh_common_args='-o ProxyJump=${params.SSH_USER}@${bastionHost} -o StrictHostKeyChecking=no'"
            }
            lines << ""
            lines << "[rocky_servers:vars]"
            lines << "ansible_become=true"
            lines << "ansible_become_method=sudo"
            lines << "ansible_become_user=root"

            writeFile file: env.RUNTIME_INVENTORY, text: lines.join("\n") + "\n"
          }
        }
      }
    }

    stage('Show Inventory (sanity check)') {
      steps {
        sh '''
          echo "===== Runtime Inventory ====="
          cat "$RUNTIME_INVENTORY"
          echo "============================="
        '''
      }
    }

    stage('Ansible Version Check') {
      steps {
        sh 'ansible --version'
      }
    }

    stage('Ansible Ping Test') {
      when {
        expression { return params.DO_PING_TEST }
      }
      steps {
        sshagent(credentials: [params.SSH_CREDENTIALS_ID]) {
          sh '''
            set -e
            ansible all -i "$RUNTIME_INVENTORY" -m ping
          '''
        }
      }
    }

    stage('Run Playbook') {
      steps {
        sshagent(credentials: [params.SSH_CREDENTIALS_ID]) {
          sh '''
            set -e

            # 필요 시 RUN_MODE를 extra-vars로 넘겨서 플레이북/롤 내부에서 분기 가능
            ansible-playbook -i "$RUNTIME_INVENTORY" "$PLAYBOOK_PATH" \
              -e "run_mode=${RUN_MODE}" | tee "${COLLECTED_LOGS_DIR}/ansible_run.log"
          '''
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'generated/**, collected_logs/**', allowEmptyArchive: true
      echo '🧹 Pipeline finished'
    }
    success {
      echo '✅ Pipeline SUCCESS'
    }
    failure {
      echo '❌ Pipeline FAILED'
    }
  }
}