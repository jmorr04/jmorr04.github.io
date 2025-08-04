// wave.js
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.wave').forEach(el => {
    const text = el.textContent;
    el.textContent = '';
    [...text].forEach((char, i) => {
      const span = document.createElement('span');
      span.style.setProperty('--i', i);
      span.textContent = char === ' ' ? '\u00A0' : char;
      el.appendChild(span);
    });
  });
});
