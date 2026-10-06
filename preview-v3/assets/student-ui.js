(() => {
  document.addEventListener("click", async (e) => {
    const copy=e.target.closest("[data-copy]");
    if(copy){
      e.preventDefault();
      const text=copy.dataset.copy||"";
      try{
        await navigator.clipboard.writeText(text);
        const old=copy.textContent; copy.textContent="Скопировано ✓"; copy.classList.add("done");
        setTimeout(()=>{copy.textContent=old;copy.classList.remove("done")},1500);
      }catch(_){copy.textContent="Не скопировалось";}
      return;
    }
    const filter=e.target.closest("[data-tool-filter]");
    if(filter){
      document.querySelectorAll("[data-tool-filter]").forEach(b=>b.classList.toggle("active",b===filter));
      const cat=filter.dataset.toolFilter;
      document.querySelectorAll("[data-tool-cats]").forEach(card=>{
        const cats=card.dataset.toolCats.split(/\s+/);
        card.hidden=cat!=="all"&&!cats.includes(cat);
      });
      const u=new URL(location.href);u.searchParams.set("filter",cat);history.replaceState(null,"",u);
    }
  });
  const q=new URLSearchParams(location.search).get("filter");
  const start=document.querySelector(`[data-tool-filter="${q||"chat"}"]`)||document.querySelector("[data-tool-filter]");
  start?.click();
})();