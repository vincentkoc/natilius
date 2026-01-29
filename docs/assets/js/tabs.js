// Ensure tabs work correctly
document.addEventListener('DOMContentLoaded', function() {
  // Check first radio in each tabbed-set by default if none checked
  document.querySelectorAll('.tabbed-set').forEach(function(tabset) {
    const inputs = tabset.querySelectorAll('input[type="radio"]');
    const hasChecked = Array.from(inputs).some(input => input.checked);
    if (!hasChecked && inputs.length > 0) {
      inputs[0].checked = true;
    }
  });
});
