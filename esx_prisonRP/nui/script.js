let tutorialSteps = [];
let currentStep = 0;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "updateSchedule") {
        document.getElementById('schedule').classList.remove('hidden');
        document.getElementById('currentPhase').innerText = data.phase;
    }

    if (data.action === "startProgress") {
        const progressDiv = document.getElementById('progress');
        const progressFill = document.getElementById('progressFill');
        const progressLabel = document.getElementById('progressLabel');

        progressDiv.classList.remove('hidden');
        progressLabel.innerText = data.label || "En cours...";
        progressFill.style.width = "0%";

        let duration = data.duration || 5000;
        let start = Date.now();

        let interval = setInterval(() => {
            let elapsed = Date.now() - start;
            let percent = (elapsed / duration) * 100;

            if (percent >= 100) {
                percent = 100;
                clearInterval(interval);
                setTimeout(() => {
                    progressDiv.classList.add('hidden');
                }, 500);
            }

            progressFill.style.width = percent + "%";
        }, 50);
    }

    if (data.action === "showTutorial") {
        tutorialSteps = data.steps || [];
        if (tutorialSteps.length > 0) {
            currentStep = 0;
            document.getElementById('tutorial').classList.remove('hidden');
            document.getElementById('tutorialText').innerText = tutorialSteps[currentStep];
        }
    }
});

document.getElementById('nextTutorial').addEventListener('click', function() {
    currentStep++;
    if (currentStep < tutorialSteps.length) {
        document.getElementById('tutorialText').innerText = tutorialSteps[currentStep];
    } else {
        document.getElementById('tutorial').classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/closeTutorial`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
});
