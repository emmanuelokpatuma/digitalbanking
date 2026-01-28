#!/usr/bin/env groovy

def call() {
    def date = new Date().format('yyyyMMdd')
    def tag = "${date}.${env.BUILD_NUMBER}"
    
    echo "Generated build tag: ${tag}"
    
    return tag
}
