(function(){
  /* ================================================
     Advensys Blog Comments – localStorage persistence
     Static comments are hardcoded in the HTML.
     This script only handles NEW comments submitted
     via the form, saves them to localStorage, and
     appends them below the static ones.
     ================================================ */

  // --- Helpers ---------------------------------------------------

  function getBlogSlug(){
    var p=window.location.pathname.replace(/\/index\.html$/,'').replace(/\/$/,'');
    var parts=p.split('/');
    return parts[parts.length-1]||'unknown';
  }

  function getLang(){
    var lang=document.documentElement.lang||'';
    if(lang.indexOf('en')===0) return 'en';
    if(window.location.pathname.indexOf('/en/')!==-1) return 'en';
    return 'fr';
  }

  function escapeHtml(str){
    var d=document.createElement('div');
    d.appendChild(document.createTextNode(str));
    return d.innerHTML;
  }

  function formatDate(dateStr){
    var mFr=['janvier','fevrier','mars','avril','mai','juin','juillet','aout','septembre','octobre','novembre','decembre'];
    var mEn=['January','February','March','April','May','June','July','August','September','October','November','December'];
    var p=dateStr.split('-');
    var y=p[0],m=parseInt(p[1],10)-1,d=parseInt(p[2],10);
    if(getLang()==='en') return mEn[m]+' '+d+', '+y;
    return d+' '+mFr[m]+' '+y;
  }

  // --- localStorage read / write ---------------------------------

  var STORAGE_KEY='advensys_blog_comments';

  function loadSavedComments(){
    try{
      var raw=localStorage.getItem(STORAGE_KEY);
      var all=raw?JSON.parse(raw):{};
      var key=getBlogSlug()+'_'+getLang();
      return all[key]||[];
    }catch(e){return [];}
  }

  function saveComment(author,text){
    try{
      var raw=localStorage.getItem(STORAGE_KEY);
      var all=raw?JSON.parse(raw):{};
      var key=getBlogSlug()+'_'+getLang();
      if(!all[key]) all[key]=[];
      var now=new Date();
      var ds=now.getFullYear()+'-'+String(now.getMonth()+1).padStart(2,'0')+'-'+String(now.getDate()).padStart(2,'0');
      var newId=all[key].length?Math.max.apply(null,all[key].map(function(c){return c.id;}))+1:1;
      all[key].push({id:newId,author:author,date:ds,text:text});
      localStorage.setItem(STORAGE_KEY,JSON.stringify(all));
      return all[key];
    }catch(e){return [];}
  }

  // --- Rendering -------------------------------------------------

  // Count static <li> already in the HTML
  function countStaticComments(){
    var list=document.getElementById('comment-list');
    if(!list) return 0;
    return list.querySelectorAll('li.comment.static-comment').length;
  }

  // Build one comment <li> HTML
  function buildCommentHtml(c,idx){
    var border=idx%2===0?'border:2px solid #FFC200;':'border:2px solid #00226E;';
    return '<li class="comment saved-comment" id="saved-comment-'+c.id+'">'
      +'<article style="margin-bottom:30px;padding:15px;'+border+'">'
      +'<div class="comment-meta" style="display:flex;justify-content:space-between;flex-direction:column;">'
      +'<span class="fn" style="font:600 20px \'Barlow\',sans-serif;color:#00226E;text-transform:capitalize;">'+escapeHtml(c.author)+'</span>'
      +'<time style="font:600 14px \'Barlow\',sans-serif;color:#00226E;">'+formatDate(c.date)+'</time>'
      +'</div>'
      +'<div class="comment-content" style="font:400 16px \'Barlow\',sans-serif;color:#00226E;margin-top:10px;line-height:1.5;">'+escapeHtml(c.text)+'</div>'
      +'</article></li>';
  }

  // Render saved (localStorage) comments after the static ones
  function renderSavedComments(){
    var list=document.getElementById('comment-list');
    if(!list) return;
    // Remove previously rendered saved comments
    var old=list.querySelectorAll('.saved-comment');
    for(var i=0;i<old.length;i++) old[i].remove();
    // Append saved comments
    var saved=loadSavedComments();
    var staticCount=countStaticComments();
    var html='';
    for(var j=0;j<saved.length;j++){
      html+=buildCommentHtml(saved[j],staticCount+j);
    }
    list.insertAdjacentHTML('beforeend',html);
    // Update the comment count header
    updateCount(staticCount+saved.length);
  }

  function updateCount(total){
    var el=document.querySelector('.comments-title');
    if(!el) return;
    var img=el.querySelector('img');
    var imgHtml=img?img.outerHTML:'';
    var lang=getLang();
    var word=lang==='en'?(total===1?'Comment':'Comments'):(total===1?'Commentaire':'Commentaires');
    el.innerHTML=imgHtml+'\n'+total+' '+word+'           ';
  }

  // --- Init ------------------------------------------------------

  function init(){
    // Redirect form away from server endpoint
    var form=document.getElementById('commentform');
    if(form) form.setAttribute('action','javascript:void(0)');

    // Render any previously saved comments from localStorage
    renderSavedComments();

    // Handle new submissions
    if(form){
      form.addEventListener('submit',function(e){
        e.preventDefault();
        var authorEl=document.getElementById('author');
        var commentEl=document.getElementById('comment');
        if(!authorEl||!commentEl) return;
        var author=authorEl.value.trim();
        var text=commentEl.value.trim();
        if(!author||!text) return;
        saveComment(author,text);
        renderSavedComments();
        commentEl.value='';
        var list=document.getElementById('comment-list');
        if(list&&list.lastElementChild){
          list.lastElementChild.scrollIntoView({behavior:'smooth',block:'center'});
        }
      });
    }
  }

  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded',init);
  }else{
    init();
  }
})();
