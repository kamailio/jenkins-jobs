pipeline {
    agent any
    stages {
        stage("Initialization") {
            steps {
                buildName "#${BUILD_NUMBER} ${distribution}"
            }
        }
        stage('clean workspace') {
            steps {
                deleteDir()
            }
        }
        stage('copy artifacts') {
            steps {
                copyArtifacts filter: 'source.tar.gz', fingerprintArtifacts: true, projectName: '{{ name }}-get-code', selector: buildParameter('BUILD_SELECTOR')
            }
        }
        stage('Build source') {
            environment {
                debian_dir="{{ debian_dir }}"
            }
            steps {
                sh 'tar -xzf source.tar.gz'
                sh 'rm source.tar.gz'
                sh '/home/admin/jenkins-jobs/scripts/jdg-generate-source'
            }
        }
        stage('store artifacts') {
            steps {
                archiveArtifacts artifacts: '*.gz,*.bz2,*.xz,*.deb,*.dsc,*.changes', fingerprint: true, followSymlinks: false
            }
        }
        stage('trigger build') {
            steps {
{%- for arch in architectures %}
                build wait: false, propagate: false, job: '{{ name }}-binaries', parameters: [string(name: 'distribution', value: "${distribution}"), string(name: 'architecture', value: '{{ arch }}')]
{%- endfor %}
            }
        }
    }
    post {
        failure {
            emailext body: '{{ email_body }}',
                    to: '{{ email }}',
                    subject: 'Build failed in Jenkins: $PROJECT_NAME - $BUILD_DISPLAY_NAME'
        }
    }
}
