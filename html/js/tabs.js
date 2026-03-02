// when the page loads, test if hash exists and
// show that tab
$(document).ready(function () {
  let hash = document.location.hash;
  if (hash) {
    $(`a[href="${hash}"]`).tab('show');
  }
});

// when the hash changes, test if hash exists and
// show that tab
window.addEventListener('hashchange', e => {
  let hash = e.target.location.hash;
  if (hash) {
    $(`a[href="${hash}"]`).tab('show');
  }
});
