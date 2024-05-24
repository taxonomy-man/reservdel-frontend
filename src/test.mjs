export function console_log_1(msg) {
  console.log(msg);
}

export function animateElement(id) {
  try {
    const element = document.getElementById(id);
    element.animate([
      { opacity: 0 },
      { opacity: 1 }
    ], {
      duration: 150,
      easing: 'ease-out'
    });
  } catch (error) {
    
  }
}
