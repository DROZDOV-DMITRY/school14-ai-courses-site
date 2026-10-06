(() => {
  const fine = matchMedia("(pointer:fine)").matches;
  const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const mascot = document.getElementById("homeMascot");
  if (!fine || reduced) return;

  let lastDot=0, mx=0, my=0, raf=0;
  function moveEyes(){
    raf=0;
    if(!mascot) return;
    const r=mascot.getBoundingClientRect();
    const cx=r.left+r.width/2, cy=r.top+r.height*.36;
    const dx=Math.max(-5,Math.min(5,(mx-cx)/45));
    const dy=Math.max(-4,Math.min(4,(my-cy)/45));
    mascot.style.setProperty("--eye-x",dx+"px");
    mascot.style.setProperty("--eye-y",dy+"px");
  }
  addEventListener("pointermove", e => {
    mx=e.clientX; my=e.clientY;
    if(!raf) raf=requestAnimationFrame(moveEyes);
    const now=performance.now();
    if(now-lastDot<34) return;
    lastDot=now;
    const dot=document.createElement("span");
    dot.className="trail-dot";
    dot.style.left=e.clientX+"px";
    dot.style.top=e.clientY+"px";
    document.body.appendChild(dot);
    setTimeout(()=>dot.remove(),560);
  }, {passive:true});
})();