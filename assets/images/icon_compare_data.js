const svgs = {
    original: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bgGradient)"/><circle cx="512" cy="512" r="340" stroke="white" stroke-width="50" fill="none" opacity="1" filter="url(#glow)"/><path d="M 220 672 L 370 320 L 512 395 L 654 320 L 804 672" stroke="white" stroke-width="50" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="1" filter="url(#glow)"/><circle cx="512" cy="395" r="42" fill="white" opacity="1" filter="url(#glow)"/></svg>`,

    v1: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg1" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow1"><feGaussianBlur stdDeviation="8" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg1)"/><circle cx="512" cy="420" r="280" stroke="white" stroke-width="42" fill="none" opacity="0.98" filter="url(#glow1)"/><path d="M 270 580 L 380 250 L 512 315 L 644 250 L 754 580" stroke="white" stroke-width="42" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="0.98" filter="url(#glow1)"/><circle cx="512" cy="315" r="35" fill="white" opacity="0.98" filter="url(#glow1)"/><text x="512" y="830" font-family="SF Pro Display, -apple-system, system-ui" font-size="105" font-weight="400" letter-spacing="10" fill="white" text-anchor="middle" opacity="0.90">mont</text></svg>`,

    v2: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg2" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow2"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg2)"/><circle cx="512" cy="450" r="320" stroke="white" stroke-width="45" fill="none" opacity="1" filter="url(#glow2)"/><path d="M 230 620 L 360 270 L 512 345 L 664 270 L 794 620" stroke="white" stroke-width="45" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="1" filter="url(#glow2)"/><circle cx="512" cy="345" r="38" fill="white" opacity="1" filter="url(#glow2)"/><text x="512" y="730" font-family="SF Pro Display, -apple-system, system-ui" font-size="95" font-weight="300" letter-spacing="12" fill="white" text-anchor="middle" opacity="0.88">mont</text></svg>`,

    v3: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg3" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow3"><feGaussianBlur stdDeviation="9" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg3)"/><circle cx="512" cy="400" r="260" stroke="white" stroke-width="40" fill="none" opacity="0.95" filter="url(#glow3)"/><path d="M 290 550 L 400 240 L 512 300 L 624 240 L 734 550" stroke="white" stroke-width="40" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="0.95" filter="url(#glow3)"/><circle cx="512" cy="300" r="32" fill="white" opacity="0.95" filter="url(#glow3)"/><text x="512" y="780" font-family="SF Pro Display, -apple-system, system-ui" font-size="120" font-weight="200" letter-spacing="18" fill="white" fill-opacity="0.85" text-anchor="middle">Mont</text></svg>`,

    v4: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg4" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow4"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg4)"/><circle cx="512" cy="512" r="340" stroke="white" stroke-width="50" fill="none" opacity="1" filter="url(#glow4)"/><path d="M 220 672 L 370 320 L 512 395 L 654 320 L 804 672" stroke="white" stroke-width="50" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="1" filter="url(#glow4)"/><circle cx="512" cy="395" r="42" fill="white" opacity="1" filter="url(#glow4)"/><text x="512" y="740" font-family="SF Pro Rounded, -apple-system, BlinkMacSystemFont, system-ui" font-size="90" font-weight="400" letter-spacing="5" fill="white" text-anchor="middle" opacity="0.88" style="paint-order: stroke; stroke: rgba(255,255,255,0.2); stroke-width: 1px;">Mont</text></svg>`,

    v5: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg5" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow5"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg5)"/><circle cx="512" cy="480" r="320" stroke="white" stroke-width="48" fill="none" opacity="1" filter="url(#glow5)"/><path d="M 230 650 L 365 300 L 512 370 L 659 300 L 794 650" stroke="white" stroke-width="48" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="1" filter="url(#glow5)"/><circle cx="512" cy="370" r="40" fill="white" opacity="1" filter="url(#glow5)"/><text x="512" y="870" font-family="SF Pro Rounded, -apple-system, system-ui" font-size="100" font-weight="500" letter-spacing="6" fill="white" text-anchor="middle" opacity="0.85">mont</text></svg>`,

    v6: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg6" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow6"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter><filter id="textGlow"><feGaussianBlur stdDeviation="4" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg6)"/><circle cx="512" cy="490" r="330" stroke="white" stroke-width="48" fill="none" opacity="0.98" filter="url(#glow6)"/><path d="M 220 665 L 365 305 L 512 375 L 659 305 L 804 665" stroke="white" stroke-width="48" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="0.98" filter="url(#glow6)"/><circle cx="512" cy="375" r="40" fill="white" opacity="0.98" filter="url(#glow6)"/><text x="512" y="750" font-family="SF Pro Rounded, -apple-system, system-ui" font-size="95" font-weight="450" letter-spacing="7" fill="white" text-anchor="middle" opacity="0.90" filter="url(#textGlow)">mont</text></svg>`,

    v7: `<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bg7" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#06B6D4;stop-opacity:1" /><stop offset="50%" style="stop-color:#14B8A6;stop-opacity:1" /><stop offset="100%" style="stop-color:#10B981;stop-opacity:1" /></linearGradient><filter id="glow7"><feGaussianBlur stdDeviation="10" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="1024" height="1024" rx="180" fill="url(#bg7)"/><circle cx="512" cy="435" r="289" stroke="white" stroke-width="42.5" fill="none" opacity="1" filter="url(#glow7)"/><path d="M 260 579 L 384 297 L 512 360 L 640 297 L 764 579" stroke="white" stroke-width="42.5" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="1" filter="url(#glow7)"/><circle cx="512" cy="360" r="35.7" fill="white" opacity="1" filter="url(#glow7)"/><text x="512" y="880" font-family="SF Pro Display, -apple-system, system-ui" font-size="140" font-weight="300" letter-spacing="20" fill="white" fill-opacity="0.88" text-anchor="middle">Mont</text></svg>`
};

const versionNames = {
    original: '오리지널',
    v1: '클래식',
    v2: '컴팩트',
    v3: '엘레강스',
    v4: '하모니',
    v5: '소프트',
    v6: '밸런스드',
    v7: '파이널'
};

let selectedVersion = 'original';

function drawIcon(canvasId, svgCode, size) {
    const canvas = document.getElementById(canvasId);
    const ctx = canvas.getContext('2d');
    const img = new Image();
    const blob = new Blob([svgCode], {type: 'image/svg+xml'});
    const url = URL.createObjectURL(blob);

    img.onload = function() {
        ctx.clearRect(0, 0, size, size);
        ctx.drawImage(img, 0, 0, size, size);
        URL.revokeObjectURL(url);
    };

    img.src = url;
}

// 미리보기 그리기
drawIcon('canvas-original', svgs.original, 256);
drawIcon('canvas-v1', svgs.v1, 256);
drawIcon('canvas-v2', svgs.v2, 256);
drawIcon('canvas-v3', svgs.v3, 256);
drawIcon('canvas-v4', svgs.v4, 256);
drawIcon('canvas-v5', svgs.v5, 256);
drawIcon('canvas-v6', svgs.v6, 256);
drawIcon('canvas-v7', svgs.v7, 256);

// 카드 클릭 이벤트
document.querySelectorAll('.card').forEach(card => {
    card.addEventListener('click', function() {
        document.querySelectorAll('.card').forEach(c => c.classList.remove('selected'));
        this.classList.add('selected');
        selectedVersion = this.dataset.version;
        document.getElementById('selected-name').textContent = versionNames[selectedVersion];
    });
});

function downloadSelected() {
    const canvas = document.getElementById('full-canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    const blob = new Blob([svgs[selectedVersion]], {type: 'image/svg+xml'});
    const url = URL.createObjectURL(blob);

    img.onload = function() {
        ctx.clearRect(0, 0, 1024, 1024);
        ctx.drawImage(img, 0, 0, 1024, 1024);

        canvas.toBlob(function(blob) {
            const link = document.createElement('a');
            link.download = 'mont_icon_' + selectedVersion + '.png';
            link.href = URL.createObjectURL(blob);
            link.click();
        }, 'image/png');

        URL.revokeObjectURL(url);
    };

    img.src = url;
}
