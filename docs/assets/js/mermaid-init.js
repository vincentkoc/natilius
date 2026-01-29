// Initialize Mermaid diagrams
document.addEventListener('DOMContentLoaded', function() {
  if (typeof mermaid !== 'undefined') {
    mermaid.initialize({
      startOnLoad: false,
      theme: 'neutral',
      securityLevel: 'loose'
    });
    // Find all mermaid code blocks and render them
    document.querySelectorAll('pre.mermaid, .mermaid').forEach(function(el) {
      if (el.tagName === 'PRE') {
        const code = el.textContent;
        const div = document.createElement('div');
        div.className = 'mermaid';
        div.textContent = code;
        el.parentNode.replaceChild(div, el);
      }
    });
    mermaid.run();
  }
});
