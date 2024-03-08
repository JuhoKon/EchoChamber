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
        this.container = document.getElementById('visual-container');
        this.slider = document.getElementById('lobby_volume');
        this.setupAudioVisualizer();
        this.handleEvent('play', ({ url }) => {
            const currentSrc = this.player.src;
            if (currentSrc === url && this.player.paused) {
                this.play();
            } else if (currentSrc !== url) {
                this.player.src = url;
                this.play();
            }
        });
        this.handleEvent('play_pause', () => {
            if (this.player.paused) {
                this.play();
            }
        });
        this.handleEvent('pause', () => this.pause());
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
    },
    setupAudioVisualizer() {
        this.audioVisualizer = new AudioMotionAnalyzer(this.container, {
            source: this.player,
            mode: 2,
            alphaBars: false,
            ansiBands: false,
            barSpace: 0.25,
            channelLayout: 'single',
            colorMode: 'bar-level',
            frequencyScale: 'log',
            gradient: 'prism',
            ledBars: false,
            linearAmplitude: true,
            linearBoost: 1.6,
            lumiBars: false,
            maxFreq: 16000,
            minFreq: 30,
            mirror: 0,
            radial: false,
            reflexRatio: 0.5,
            reflexAlpha: 1,
            roundBars: true,
            showPeaks: false,
            showScaleX: false,
            smoothing: 0.7,
            overlay: true,
            showBgColor: true,
            bgAlpha: 0,
            weightingFilter: 'D'
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
