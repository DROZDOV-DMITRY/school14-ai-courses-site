(() => {
  const ROOT="/school14-ai-courses-site/preview-v3/";
  const here=location.pathname.endsWith("/preview-v3/") || location.pathname.endsWith("/preview-v3/index.html");

  document.querySelectorAll('a[href]').forEach(a=>{
    try{
      const u=new URL(a.getAttribute('href'), location.href);
      const internal=u.origin===location.origin && u.pathname.startsWith("/school14-ai-courses-site/");
      if(internal){
        a.removeAttribute("target");
        if(a.getAttribute("rel")==="noopener") a.removeAttribute("rel");
      }else if(/^https?:$/.test(u.protocol)){
        a.target="_blank";
        a.rel="noopener";
      }
    }catch(_){}
  });

  if(here) return;
  document.body.classList.add("with-global-nav");
  const holder=document.createElement("div");
  holder.className="student-global-nav";
  holder.innerHTML='<button type="button" class="nav-big nav-back">← Назад</button><a class="nav-big nav-home" href="'+ROOT+'">⌂ Главная</a>';
  const top=document.querySelector(".topbar .inner");
  if(top) top.appendChild(holder); else document.body.prepend(holder);
  holder.querySelector(".nav-back").addEventListener("click",()=>{
    const ref=document.referrer||"";
    if(ref.includes("/school14-ai-courses-site/preview-v3/")) history.back();
    else location.href=ROOT;
  });
})();