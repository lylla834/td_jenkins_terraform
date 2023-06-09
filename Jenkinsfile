pipeline {
    agent any
    tools {terraform 'terraform'}
    stages {
        stage('recup') {            steps{          checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/lylla834/td_jenkins_terraform']]) }}
        stage('terraform init') {
            steps{
                sh 'terraform init'
                 echo 'terraform init succeed'}
        }
        stage('terraform plan') {      	
           steps{                       	
            	sh 'terraform plan'                		
	            echo 'terraform plan succeed'}           
        } 
		stage('terraform apply') {         
           steps{                            
                sh 'terraform apply -auto-approve'           
                echo 'terraform apply succeed'}              
        }
        
        }
    }



