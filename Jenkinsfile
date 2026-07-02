// Paste this directly into Jenkins UI:
// New Item → Pipeline → Pipeline tab → Pipeline script
//
// Prerequisites:
// - GitHub plugin installed in Jenkins
// - In Jenkins job: Build Triggers → check "GitHub hook trigger for GITScm polling"
// - In GitHub repo: Settings → Webhooks → Add webhook
//   Payload URL: http://<your-jenkins-url>/github-webhook/
//   Content type: application/json
//   Event: Just the push event

// Set job-level trigger via properties step (runs once on first build to register the trigger)
properties([
    pipelineTriggers([githubPush()])
])

node {
    stage('Checkout') {
        echo "Triggered by GitHub webhook push event"
        checkout scm
        echo "Branch: ${env.GIT_BRANCH}"
        echo "Commit: ${env.GIT_COMMIT}"
    }

    stage('Build') {
        echo "Building after push to ${env.GIT_BRANCH}..."
    }

    stage('Test') {
        echo "Running tests..."
    }

    stage('Deploy') {
        echo "Deploying..."
    }
}
