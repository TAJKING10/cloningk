import os
import re

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove method="post" and enctype="multipart/form-data"
    content = re.sub(r'\bmethod=["\']post["\']', '', content, flags=re.I)
    content = re.sub(r'\benctype=["\']multipart/form-data["\']', '', content, flags=re.I)

    # 2. Update button and input tags
    # We'll assign IDs to buttons that might be used by EmailJS
    btn_id_counter = 0
    
    def button_repl(match):
        nonlocal btn_id_counter
        tag_content = match.group(1)
        
        # Change type
        if re.search(r'\btype=["\']submit["\']', tag_content, re.I):
            tag_content = re.sub(r'\btype=["\']submit["\']', 'type="button"', tag_content, flags=re.I)
        elif 'type=' not in tag_content.lower():
            tag_content = ' type="button"' + tag_content
            
        # Add ID if it's a candidate for EmailJS and has no ID
        if 'frm_button_submit' in tag_content and 'id=' not in tag_content.lower():
            btn_id_counter += 1
            tag_content = f' id="send_btn_gen_{btn_id_counter}"' + tag_content
            
        # For Newsletter buttons, add onclick if not already there
        if 'tnp-submit' in tag_content and 'onclick' not in tag_content.lower():
            tag_content += ' onclick="if(typeof newsletter_check === \'function\'){ if(newsletter_check(this.form)) this.form.submit(); } else { this.form.submit(); }"'
        
        return f'<button{tag_content}'

    content = re.sub(r'<button([^>]*)', button_repl, content)

    def input_repl(match):
        tag_content = match.group(1)
        if re.search(r'\btype=["\']submit["\']', tag_content, re.I):
            tag_content = re.sub(r'\btype=["\']submit["\']', 'type="button"', tag_content, flags=re.I)
            
            if 'tnp-submit' in tag_content:
                if 'onclick' not in tag_content.lower():
                    tag_content += ' onclick="if(typeof newsletter_check === \'function\'){ if(newsletter_check(this.form)) this.form.submit(); } else { this.form.submit(); }"'
            elif 'onclick' not in tag_content.lower():
                tag_content += ' onclick="this.form.submit()"'
        return f'<input{tag_content}'

    content = re.sub(r'<input([^>]*)', input_repl, content)

    # 3. Update JavaScript Listeners
    # We need to handle both the loop-based listener and the single-form listener
    
    # Loop-based (e.g., index.html)
    # Search for: form.addEventListener('submit',function(e){e.preventDefault();
    # Replace with logic that finds the button and attaches click
    
    # We'll use a more generic replacement for the listener attachment
    
    # This regex matches the common pattern for EmailJS form submission listeners in this project
    pattern = r'(form\.addEventListener\([\'"]submit[\'"],\s*function\(e\)\{\s*)e\.preventDefault\(\);'
    
    replacement = r'''var submitBtn = form.querySelector('.frm_button_submit') || form.querySelector('button[type="button"]') || form.querySelector('input[type="button"]');
    if(!submitBtn) return;
    if(!submitBtn.id) submitBtn.id = 'send_btn_' + Math.random().toString(36).substr(2, 9);
    document.getElementById(submitBtn.id).addEventListener('click', function(e){
      e.preventDefault();'''
    
    content = re.sub(pattern, replacement, content)

    # Some files might use 'this' instead of 'form' if they are not in a loop, but I haven't seen that yet.
    # Also handle cases where the closure uses a different variable name or structure.
    
    # Specifically check for the contact page style
    # (function(){ var form = document.getElementById('form_contact-form'); ... form.addEventListener('submit', ... ) })()
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

root_dir = 'advensys-conseil.lu'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.html'):
            process_file(os.path.join(root, file))

print("Processing complete.")
