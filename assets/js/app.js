import 'phoenix_html';

import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';
import topbar from '../vendor/topbar';
import AudioMotionAnalyzer from 'audiomotion-analyzer';

// Hooks
const Hooks = {};

Hooks.AudioPlayer = {
    mounted() {
        this.player = this.el.querySelector('audio');
        this.player.volume = 0.5; // Set to 50% by default
        this.slider = document.getElementById('lobby_volume');
        this.handleEvent('play', ({ url }) => {
            const currentSrc = this.player.src;
            if (currentSrc === url && this.player.paused) {
                this.play();
            } else if (currentSrc !== url) {
                this.player.src = url;
                this.play();
            }
        });

        this.handleEvent('pause', () => this.pause());

        this.handleEvent('stop', () => this.stop());

        if (this.slider) {
            this.slider.addEventListener('input', (event) => {
                this.player.volume = event.target.value / 100;
            });
        }
    },

    play() {
        this.player.play();
    },

    pause() {
        this.player.pause();
    },

    stop() {
        this.player.pause();
    }
};

Hooks.AudioMotionAnalyzerLobby = {
    mounted() {
        this.player = this.el.querySelector('audio');
        this.container = document.getElementById('visual-container');
        this.setupAudioVisualizer();
    },

    setupAudioVisualizer() {
        this.audioVisualizer = new AudioMotionAnalyzer(this.container, {
            source: this.player,
            mode: 5,
            barSpace: 2,
            channelLayout: 'single',
            gradient: 'prism',
            ledBars: false,
            maxFreq: 20000,
            minFreq: 20,
            mirror: 0,
            radial: true,
            showBgColor: true,
            showPeaks: true,
            spinSpeed: 2,
            overlay: true,
            bgAlpha: 0,
            showScaleX: 0
        });
        this.audioVisualizer.registerGradient('custom-gradient', {
            dir: 'h',
            colorStops: [
                { color: '#6a00ff', pos: 0 },
                { color: '#0072ff', pos: 0.25 },
                { color: '#00ff00', pos: 0.5 },
                { color: '#ffea00', pos: 0.75 },
                { color: '#ff6a00', pos: 1 }
            ]
        });
        this.audioVisualizer.setOptions({
            gradient: 'custom-gradient'
        });
    }
};

Hooks.AudioMotionAnalyzerAdmin = {
    mounted() {
        this.player = this.el.querySelector('audio');
        this.container = document.getElementById('visual-container');
        this.setupAudioVisualizer();
    },

    setupAudioVisualizer() {
        this.audioVisualizer = new AudioMotionAnalyzer(this.container, {
            source: this.player,
            mode: 10,
            alphaBars: false,
            ansiBands: false,
            barSpace: 0.25,
            gradient: 'prism',
            ledBars: false,
            linearAmplitude: true,
            lineWidth: 1,
            linearBoost: 1.6,
            reflexAlpha: 1,
            reflexBright: 1,
            reflexRatio: 0.5,
            lumiBars: false,
            maxFreq: 16000,
            minFreq: 30,
            mirror: 1,
            radial: false,
            showPeaks: false,
            showScaleX: false,
            smoothing: 0.7,
            overlay: true,
            showBgColor: true,
            bgAlpha: 0,
            weightingFilter: 'D'
        });
        this.audioVisualizer.registerGradient('custom-gradient-admin', {
            dir: 'h',
            colorStops: [{ color: '#000', pos: 1 }]
        });
        this.audioVisualizer.setOptions({
            gradient: 'custom-gradient-admin'
        });
    }
};

let csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
    hooks: Hooks,
    longPollFallbackMs: 2500,
    params: { _csrf_token: csrfToken }
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' });
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300));
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
