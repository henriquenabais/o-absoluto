let chapters=[],phrases=[];
const menu=document.querySelector("#menu"),app=document.querySelector("#app");
function esc(s){return s.replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]))}
function drawMenu(){menu.innerHTML=chapters.map(c=>`<a data-section="${c.slug}" href="#${c.slug}">${c.title}</a>`).join("")+`<a data-section="frases" href="#frases">Frases</a><a data-section="forum" href="#forum">Fórum</a>`}
function markActive(section){menu.querySelectorAll("a").forEach(a=>a.classList.toggle("active",a.dataset.section===section))}
function chapter(c){app.innerHTML=`<h1>${c.title}</h1><div class="content">${c.html}</div>`}
function list(q=""){let x=phrases.filter(p=>!q||String(p.id).includes(q)||p.text.toLowerCase().includes(q.toLowerCase()));app.innerHTML=`<h1>Frases</h1><input id="phraseSearch" class="searchbox" placeholder="Pesquisar por número ou texto…" value="${esc(q)}"><ul class="phrase-list">${x.map(p=>`<li><a href="#frase/${p.id}"><span class="number">${p.id}</span><strong>${p.text}</strong></a></li>`).join("")}</ul>`;document.querySelector("#phraseSearch").oninput=e=>list(e.target.value)}
function renderSections(sections){return sections.map(s=>{if(s.type==="texto")return `<div class="text-block">${s.body||""}</div>`;if(s.type==="pdf")return `<div class="pdf-block"><a href="${s.file}" target="_blank" rel="noopener">Abrir PDF</a>${s.caption?`<div class="caption">${s.caption}</div>`:""}</div>`;return ""}).join("")}
function phrase(id){let i=phrases.findIndex(p=>p.id==id);if(i<0)return list();let p=phrases[i],prev=phrases[i-1],next=phrases[i+1];
let body=p.sections?renderSections(p.sections):(p.html||"");
app.innerHTML=`<div class="number">FRASE ${p.id}</div><h1 class="phrase">${p.text}</h1><div class="content">${body}</div><div class="phrase-nav"><span>${prev?`<a href="#frase/${prev.id}">← ${prev.id}</a>`:""}</span><a href="#frases">Todas as frases</a><span>${next?`<a href="#frase/${next.id}">${next.id} →</a>`:""}</span></div>`}
function search(){app.innerHTML=`<h1>Pesquisar no site</h1><p>A pesquisa abrange os capítulos e as frases; o fórum fica excluído.</p><input id="globalSearch" class="searchbox" autofocus placeholder="Escreva uma palavra, expressão ou número…"><div id="results"></div>`;let inp=document.querySelector("#globalSearch"),out=document.querySelector("#results");inp.oninput=()=>{let q=inp.value.trim().toLowerCase();if(!q){out.innerHTML="";return}let a=chapters.filter(c=>(c.title+" "+c.html.replace(/<[^>]*>/g," ")).toLowerCase().includes(q)).map(c=>`<div class="result"><div class="tag">Capítulo</div><a href="#${c.slug}"><strong>${c.title}</strong></a></div>`);let b=phrases.filter(p=>(p.id+" "+p.text+" "+(p.html||"")+" "+JSON.stringify(p.sections||[])).toLowerCase().includes(q)).map(p=>`<div class="result"><div class="tag">Frase ${p.id}</div><a href="#frase/${p.id}"><strong>${p.text}</strong></a></div>`);out.innerHTML=a.concat(b).join("")||"<p>Sem resultados.</p>"}}
function route(){let h=location.hash.slice(1)||"inicio";let section=h.startsWith("frase/")?"frases":h;markActive(section);if(h==="frases")return list();if(h.startsWith("frase/"))return phrase(h.split("/")[1]);if(h==="pesquisa")return search();if(h==="forum"){app.innerHTML="<h1>Fórum</h1><p>O fórum será externo. A ligação será adicionada quando escolhermos a plataforma.</p>";return}chapter(chapters.find(c=>c.slug===h)||chapters[0])}
document.querySelector("#searchBtn").onclick=()=>location.hash="pesquisa";
async function init(){
  try{
    [chapters,phrases]=await Promise.all([
      fetch("content/chapters.json").then(r=>{if(!r.ok)throw new Error("chapters");return r.json()}),
      fetch("data/phrases.json").then(r=>{if(!r.ok)throw new Error("phrases");return r.json()})
    ]);
    phrases.sort((a,b)=>a.id-b.id);
    drawMenu();addEventListener("hashchange",route);route();
  }catch(e){app.innerHTML="<h1>O ABSOLUTO</h1><p>Não foi possível carregar o conteúdo.</p>"}
}
init();