pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  parameters {
    // -----------------------------
    // 1) 실행 모드
    // -----------------------------
    choice(
      name: 'RUN_MODE',
      choices: ['audit', 'enforce'],
      description: 'audit=점검만 / enforce=조치 실행'
    )

    // -----------------------------
    // 2) 인벤토리 입력 방식
    // -----------------------------
    choice(
      name: 'INVENTORY_MODE',
      choices: ['manual', 'tf_artifact'],
      description: 'manual=UI에서 직접 입력 / tf_artifact=Terraform Job의 tf_output.json 사용'
    )

    // -----------------------------
    // 3) 수동 입력 모드용 파라미터
    // -----------------------------
    string(
      name: 'BASTION_IP',
      defaultValue: '',
      description: 'INVENTORY_MODE=manual일 때 bastion 공인 IP (예: 133.186.xxx.xxx)'
    )

    text(
      name: 'TARGET_PRIVATE_IPS',
      defaultValue: '',
      description: '''INVENTORY_MODE=manual일 때 대상 서버 private IP 입력
예시(쉼표/공백/줄바꿈 모두 가능):
10.0.2.45,10.0.2.36
또는
10.0.2.45
10.0.2.36'''
    )

    // -----------------------------
    // 4) Terraform 아티팩트 모드용 파라미터
    // -----------------------------
    string(
      name: 'TF_JOB_NAME',
      defaultValue: 'Terraform Job',
      description: 'tf_output.json을 가져올 Terraform Jenkins Job 이름'
    )

    string(
      name: 'TF_BUILD_NUMBER',
      defaultValue: '',
      description: '비우면 마지막 성공 빌드(lastSuccessful), 숫자 입력 시 해당 빌드번호에서 가져옴'
    )

    // -----------------------------
    // 5) Git 브랜치 / 실행 옵션
    // -----------------------------
    string(
      name: 'GIT_BRANCH',
      defaultValue: 'main',
      description: 'Ansible 레포에서 checkout할 브랜치명 (예: feature/xxx)'
    )

    string(
      name: 'ANSIBLE_LIMIT',
      defaultValue: '',
      description: '선택: 특정 호스트만 실행하고 싶을 때 (예: rocky-01)'
    )

    booleanParam(
      name: 'DRY_PING_ONLY',
      defaultValue: false,
      description: 'true면 ansible ping 테스트까지만 수행하고 플레이북은 실행하지 않음'
    )
  }

  environment {
    // Jenkins에 등록된 SSH Credential ID (SSH Username with private key)
    SSH_CRED_ID = 'bastion-ssh-key'
    GENERATED_DIR = 'generated'
    GENERATED_INVENTORY = 'generated/hosts.runtime.ini'
    GENERATED_TF_JSON = 'generated/tf_output.json'
  }

  stages {
    stage('Checkout Ansible Repo') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.GIT_BRANCH}"]],
          userRemoteConfigs: [[url: 'https://github.com/sususu25/rocky-ansible-security.git']]
        ])
      }
    }

    stage('Validate Params') {
      steps {
        script {
          if (params.INVENTORY_MODE == 'manual') {
            if (!params.BASTION_IP?.trim()) {
              error("INVENTORY_MODE=manual 인데 BASTION_IP가 비어있습니다.")
            }
            if (!params.TARGET_PRIVATE_IPS?.trim()) {
              error("INVENTORY_MODE=manual 인데 TARGET_PRIVATE_IPS가 비어있습니다.")
            }
          }

          if (params.INVENTORY_MODE == 'tf_artifact') {
            if (!params.TF_JOB_NAME?.trim()) {
              error("INVENTORY_MODE=tf_artifact 인데 TF_JOB_NAME이 비어있습니다.")
            }
          }

          if (!(params.RUN_MODE in ['audit', 'enforce'])) {
            error("RUN_MODE는 audit 또는 enforce 여야 합니다.")
          }
        }
      }
    }

    stage('Prepare Workspace') {
      steps {
        sh '''
          set -e
          mkdir -p "${GENERATED_DIR}"
          mkdir -p collected_logs
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
          if (params.TF_BUILD_NUMBER?.trim()) {
            // 특정 빌드 번호에서 가져오기
            copyArtifacts(
              projectName: params.TF_JOB_NAME,
              selector: specific(params.TF_BUILD_NUMBER.trim()),
              filter: 'tf_output.json',
              target: env.GENERATED_DIR,
              flatten: true
            )
          } else {
            // 마지막 성공 빌드에서 가져오기
            copyArtifacts(
              projectName: params.TF_JOB_NAME,
              selector: lastSuccessful(),
              filter: 'tf_output.json',
              target: env.GENERATED_DIR,
              flatten: true
            )
          }

          sh '''
            set -e
            test -f "${GENERATED_TF_JSON}"
            echo "Fetched tf_output.json:"
            ls -l "${GENERATED_TF_JSON}"
          '''
        }
      }
    }

    stage('Generate Runtime Inventory') {
      steps {
        withCredentials([
          sshUserPrivateKey(
            credentialsId: env.SSH_CRED_ID,
            keyFileVariable: 'SSH_KEY_FILE',
            usernameVariable: 'SSH_USER'
          )
        ]) {
          script {
            def bastionIp = ''
            def targetIps = []

            if (params.INVENTORY_MODE == 'manual') {
              bastionIp = params.BASTION_IP.trim()

              // 쉼표/공백/줄바꿈 모두 허용
              targetIps = params.TARGET_PRIVATE_IPS
                .split(/[\\s,]+/)
                .collect { it.trim() }
                .findAll { it }

            } else {
              // tf_output.json 파싱
              def tfRaw = readFile(file: env.GENERATED_TF_JSON)
              def tf = new groovy.json.JsonSlurperClassic().parseText(tfRaw)

              bastionIp = tf?.bastion_fip?.value?.toString()?.trim()

              def backendMap = tf?.backend_mgmt_private_ips?.value
              if (!backendMap || !(backendMap instanceof Map)) {
                error("tf_output.json에서 backend_mgmt_private_ips.value(map)를 찾지 못했습니다.")
              }

              targetIps = backendMap.values()
                .collect { it.toString().trim() }
                .findAll { it }

              if (!bastionIp) {
                error("tf_output.json에서 bastion_fip.value를 찾지 못했습니다.")
              }
            }

            if (!bastionIp) {
              error("Bastion IP가 비어 있습니다.")
            }
            if (!targetIps || targetIps.size() == 0) {
              error("대상 서버 IP가 비어 있습니다.")
            }

            // 중복 제거 (순서 유지)
            def uniqueTargetIps = []
            targetIps.each { ip ->
              if (!uniqueTargetIps.contains(ip)) {
                uniqueTargetIps << ip
              }
            }

            // host 이름 자동 생성 rocky-01 ~ n
            def hostLines = []
            for (int i = 0; i < uniqueTargetIps.size(); i++) {
              def idx = i + 1
              def hostName = String.format("rocky-%02d", idx)
              hostLines << "${hostName} ansible_host=${uniqueTargetIps[i]}"
            }

            // ProxyCommand 구성 (같은 키로 bastion -> backend)
            // %h, %p 는 원격 호스트/포트
            def proxyCmd = "-o ProxyCommand=\\\"ssh -W %h:%p -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${SSH_USER}@${bastionIp}\\\""

            def inventoryContent = """[rocky_servers]
${hostLines.join('\n')}

[rocky_servers:vars]
ansible_user=${SSH_USER}
ansible_ssh_private_key_file=${SSH_KEY_FILE}
ansible_become=true
ansible_become_method=sudo
ansible_become_user=root
ansible_ssh_common_args=${proxyCmd}
"""

            writeFile(file: env.GENERATED_INVENTORY, text: inventoryContent)

            echo "Generated inventory => ${env.GENERATED_INVENTORY}"
            echo "Bastion IP => ${bastionIp}"
            echo "Target count => ${uniqueTargetIps.size()}"
            echo "Targets => ${uniqueTargetIps.join(', ')}"
          }
        }
      }
    }

    stage('Show Inventory (sanity check)') {
      steps {
        sh '''
          set -e
          echo "===== Generated Inventory ====="
          cat "${GENERATED_INVENTORY}"
          echo "==============================="
        '''
      }
    }

    stage('Ansible Ping Test') {
      steps {
        withCredentials([
          sshUserPrivateKey(
            credentialsId: env.SSH_CRED_ID,
            keyFileVariable: 'SSH_KEY_FILE',
            usernameVariable: 'SSH_USER'
          )
        ]) {
          script {
            def limitOpt = params.ANSIBLE_LIMIT?.trim() ? "--limit '${params.ANSIBLE_LIMIT.trim()}'" : ""
            sh """
              set -e
              export ANSIBLE_HOST_KEY_CHECKING=False
              ansible --version
              ansible -i '${env.GENERATED_INVENTORY}' rocky_servers -m ping ${limitOpt}
            """
          }
        }
      }
    }

    stage('Run Playbook') {
      when {
        expression { return !params.DRY_PING_ONLY }
      }
      steps {
        withCredentials([
          sshUserPrivateKey(
            credentialsId: env.SSH_CRED_ID,
            keyFileVariable: 'SSH_KEY_FILE',
            usernameVariable: 'SSH_USER'
          )
        ]) {
          script {
            def playbookFile = (params.RUN_MODE == 'audit') ? 'playbooks/security_audit.yml' : 'playbooks/security_check.yml'
            def limitOpt = params.ANSIBLE_LIMIT?.trim() ? "--limit '${params.ANSIBLE_LIMIT.trim()}'" : ""

            sh """
              set -e
              export ANSIBLE_HOST_KEY_CHECKING=False
              ansible-playbook -i '${env.GENERATED_INVENTORY}' '${playbookFile}' ${limitOpt}
            """
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'generated/**,collected_logs/**', allowEmptyArchive: true
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