pipeline {
    agent any
    stages {
        stage('recup') {            steps{          checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/lylla834/td_jenkins_terraform']]) }
        stage('terraform init') {
            steps{
                sh 'terraform init'}
        }
        stage('terraform plan') {      	
           steps{                       	
            	sh 'terraform plan'                		
	            echo 'Login Completed'}           
        } 
		stage('terraform apply') {         
           steps{                            
                sh 'terraform apply -auto-approve'           
                echo 'terraform succeed'}              
        }
        
    }
}

