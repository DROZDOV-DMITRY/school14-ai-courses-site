(() => {
  const fine=matchMedia("(pointer:fine)").matches;
  const reduced=matchMedia("(prefers-reduced-motion: reduce)").matches;
  const friend=document.getElementById("winterFriend");
  if(!friend || !fine || reduced) return;

  const eyes=[...friend.querySelectorAll(".wf-eye")];
  let lastTrail=0, lastMove=0, autoX=0, autoY=0, raf=0, px=0, py=0;

  function snowBurst(x,y,n=7){
    for(let i=0;i<n;i++){
      const s=document.createElement("i");
      s.className="wf-snow";
      const a=(Math.PI*2*i/n)+(Math.random()*.35);
      const d=28+Math.random()*44;
      s.style.left=x+"px"; s.style.top=y+"px";
      s.style.setProperty("--dx",Math.cos(a)*d+"px");
      s.style.setProperty("--dy",Math.sin(a)*d+"px");
      document.body.appendChild(s);
      setTimeout(()=>s.remove(),850);
    }
  }
  function clearReactions(){
    friend.classList.remove("react-left","react-right","react-up","react-near");
  }
  function frame(){
    raf=0;
    const r=friend.getBoundingClientRect();
    const cx=r.left+r.width/2, cy=r.top+r.height*.45;
    const dx=px-cx, dy=py-cy, dist=Math.hypot(dx,dy);
    eyes.forEach((eye,idx)=>{
      const ex=Math.max(-5,Math.min(5,dx/40));
      const ey=Math.max(-4,Math.min(4,dy/45));
      eye.style.transform=`translate(${ex}px,${ey}px)`;
    });
    clearReactions();
    if(dist<95) friend.classList.add("react-near");          // 1: приблизился
    else if(dy<-95 && Math.abs(dx)<150) friend.classList.add("react-up"); // 2: мышь сверху
    else if(dx<-80) friend.classList.add("react-left");      // 3: мышь слева
    else if(dx>80) friend.classList.add("react-right");      // 4: мышь справа
  }
  addEventListener("pointermove",e=>{
    px=e.clientX; py=e.clientY;
    if(!raf) raf=requestAnimationFrame(frame);
    const now=performance.now();
    if(now-lastTrail>55){
      lastTrail=now;
      const dot=document.createElement("span");
      dot.className="trail-dot";dot.style.left=e.clientX+"px";dot.style.top=e.clientY+"px";
      document.body.appendChild(dot);setTimeout(()=>dot.remove(),560);
    }
  },{passive:true});

  friend.addEventListener("click",e=>{                       // 5: клик
    friend.classList.remove("react-click"); void friend.offsetWidth;
    friend.classList.add("react-click"); snowBurst(e.clientX,e.clientY,10);
    setTimeout(()=>friend.classList.remove("react-click"),700);
  });

  let dir=1;
  function wander(t){
    if(t-lastMove>2400){
      lastMove=t; autoX+=dir*(12+Math.random()*16);
      if(Math.abs(autoX)>34) dir*=-1;
      autoY=Math.max(-18,Math.min(18,autoY+(Math.random()-.5)*18));\n      friend.style.translate=`${autoX}px ${autoY}px`;
    }
    requestAnimationFrame(wander);
  }
  requestAnimationFrame(wander);
})();