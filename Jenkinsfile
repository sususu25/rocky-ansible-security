pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    // 인벤토리 입력 방식
    choice(
      name: 'INVENTORY_MODE',
      choices: ['uploaded_inventory', 'manual'],
      description: 'uploaded_inventory: Jenkins File Credential의 hosts.ini 사용 / manual: bastion+target 수기 입력'
    )

    // uploaded_inventory 모드용
    string(
      name: 'INVENTORY_CREDENTIALS_ID',
      defaultValue: 'ansible-inventory',
      description: 'uploaded_inventory 모드에서 사용할 Jenkins File Credential ID (hosts.ini)'
    )

    // manual 모드용
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
      description: 'fix: 조치 실행 / check: 점검 중심 실행'
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
    RUNTIME_INVENTORY = 'generated/hosts.ini'
    KNOWN_HOSTS_FILE = '/var/lib/jenkins/.ssh/known_hosts'
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
          if (params.INVENTORY_MODE == 'uploaded_inventory') {
            if (!params.INVENTORY_CREDENTIALS_ID?.trim()) {
              error("uploaded_inventory 모드에서는 INVENTORY_CREDENTIALS_ID 필수")
            }
          }

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

    stage('Generate Runtime Inventory') {
      steps {
        script {
          if (params.INVENTORY_MODE == 'uploaded_inventory') {
            withCredentials([file(credentialsId: params.INVENTORY_CREDENTIALS_ID, variable: 'SRC_INVENTORY')]) {
              sh '''
                set -e
                cp "$SRC_INVENTORY" "$RUNTIME_INVENTORY"
                echo "uploaded inventory copied to $RUNTIME_INVENTORY"
              '''
            }
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

    stage('Prepare SSH known_hosts') {
      steps {
        sh '''
          set -e

          mkdir -p /var/lib/jenkins/.ssh
          chmod 700 /var/lib/jenkins/.ssh
          : > "$KNOWN_HOSTS_FILE"

          # rocky_servers 그룹의 ansible_host 값 추출
          awk '
            BEGIN { in_group=0 }
            /^\\[rocky_servers\\]/ { in_group=1; next }
            /^\\[/ && $0 !~ /^\\[rocky_servers\\]/ { in_group=0 }
            in_group && $0 !~ /^#/ && NF {
              for (i=1; i<=NF; i++) {
                if ($i ~ /^ansible_host=/) {
                  split($i, a, "=")
                  print a[2]
                }
              }
            }
          ' "$RUNTIME_INVENTORY" | sort -u > /tmp/target_hosts.txt

          # ansible_ssh_common_args에서 ProxyJump 대상 추출
          grep '^ansible_ssh_common_args=' "$RUNTIME_INVENTORY" \
            | sed -n "s/.*ProxyJump=[^@]*@\\([^ ']*\\).*/\\1/p" \
            | sort -u > /tmp/bastion_hosts.txt

          echo "===== Parsed bastion hosts ====="
          cat /tmp/bastion_hosts.txt || true
          echo "===== Parsed target hosts ====="
          cat /tmp/target_hosts.txt || true

          while read -r host; do
            [ -n "$host" ] && ssh-keyscan -H "$host" >> "$KNOWN_HOSTS_FILE"
          done < /tmp/bastion_hosts.txt

          while read -r host; do
            [ -n "$host" ] && ssh-keyscan -H "$host" >> "$KNOWN_HOSTS_FILE"
          done < /tmp/target_hosts.txt

          chmod 600 "$KNOWN_HOSTS_FILE"

          echo "===== known_hosts ====="
          cat "$KNOWN_HOSTS_FILE"
          echo "======================="
        '''
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

            echo "===== Loaded SSH keys in agent ====="
            ssh-add -l || true
            echo "===================================="

            echo "===== Runtime Inventory ====="
            cat "$RUNTIME_INVENTORY"
            echo "============================="

            BASTION_HOST=$(grep '^ansible_ssh_common_args=' "$RUNTIME_INVENTORY" | sed -n "s/.*ProxyJump=[^@]*@\\([^ ']*\\).*/\\1/p" | head -n1)
            TARGET_HOST=$(awk '
              BEGIN { in_group=0 }
              /^\\[rocky_servers\\]/ { in_group=1; next }
              /^\\[/ && $0 !~ /^\\[rocky_servers\\]/ { in_group=0 }
              in_group && $0 !~ /^#/ && NF {
                for (i=1; i<=NF; i++) {
                  if ($i ~ /^ansible_host=/) {
                    split($i, a, "=")
                    print a[2]
                    exit
                  }
                }
              }
            ' "$RUNTIME_INVENTORY")

            echo "===== Direct SSH test via ProxyJump ====="
            echo "BASTION_HOST=$BASTION_HOST"
            echo "TARGET_HOST=$TARGET_HOST"

            if [ -n "$BASTION_HOST" ] && [ -n "$TARGET_HOST" ]; then
              ssh -vvv \
                -o UserKnownHostsFile="$KNOWN_HOSTS_FILE" \
                -o StrictHostKeyChecking=yes \
                -J "${SSH_USER}@${BASTION_HOST}" \
                "${SSH_USER}@${TARGET_HOST}" "hostname" || true
            else
              echo "Skip direct SSH test: bastion or target host not found in inventory"
            fi

            echo "=========================================="

            echo "===== Ansible Ping ====="
            ANSIBLE_HOST_KEY_CHECKING=True ansible all -i "$RUNTIME_INVENTORY" -m ping -vvvv
          '''
        }
      }
    }

    stage('Run Playbook') {
      steps {
        sshagent(credentials: [params.SSH_CREDENTIALS_ID]) {
          sh '''
            set -e
            ANSIBLE_HOST_KEY_CHECKING=True ansible-playbook -i "$RUNTIME_INVENTORY" "$PLAYBOOK_PATH" \
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