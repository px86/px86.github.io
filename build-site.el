(require 'ox-publish)
(require 'package)

(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(package-install 'htmlize)

;; Macro for inserting timestamps in the sitemap files
(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@")))

(defun my-sitemap-date-title-entry-format (filename style project)
  "Extract title and date from the org document and format it for sitemap entry."
  (let ((title (org-publish-find-title filename project)))
    (if (= (length title) 0)
        (format "*%s*" filename)
      (format "{{{timestamp(%s)}}} [[file:%s][%s]]"
              (format-time-string
               "%Y-%m-%d"
               (org-publish-find-date filename project))
              filename title))))

;; Set the project publish configuration
(setq org-publish-project-alist
      (list
       (list "articles"
             :recursive t
             :base-directory "./source/articles"
             :publishing-directory "./build/articles"
             :publishing-function 'org-html-publish-to-html
             :with-creator t
             :with-toc nil
             :auto-sitemap t
             :sitemap-title "All Articles"
             :sitemap-filename "index.org"
             :sitemap-style 'list
             :sitemap-format-entry #'my-sitemap-date-title-entry-format
             :sitemap-sort-files 'anti-chronologically
             :section-numbers nil)
       (list "til"
             :recursive t
             :base-directory "./source/til"
             :publishing-directory "./build/til"
             :publishing-function 'org-html-publish-to-html
             :with-creator t
             :with-toc nil
             :auto-sitemap t
             :sitemap-title "Today I Learnt"
             :sitemap-filename "index.org"
             :sitemap-style 'list
             :sitemap-format-entry #'my-sitemap-date-title-entry-format
             :sitemap-sort-files 'anti-chronologically
             :section-numbers nil)
       (list "site-pages"
             :recursive nil
             :base-directory "./source"
             :publishing-directory "./build"
             :publishing-function 'org-html-publish-to-html
             :with-creator t
             :with-toc nil
             :section-numbers nil)
       (list "static-files"
             :recursive t
             :base-directory  "./source/assets"
             :publishing-directory "./build/assets"
             :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|ico\\|pdf\\|mp3\\|wav\\|woff2?\\|ttf\\|csv"
             :publishing-function 'org-publish-attachment
             )))


(setq org-html-htmlize-output-type 'css         ;; Only add css classes into the HTML, don't include inline styles
      org-html-validation-link nil              ;; Don't include the validation service link
      org-html-head-include-scripts nil         ;; Don't include default scripts in exported documents
      org-html-head-include-default-style nil   ;; Don't include default css in exported documents
      org-html-doctype "html5"
      org-html-html5-fancy t                    ;; Use new html5 elements
      org-html-divs                             ;; Use more specific html tags instead of 'divs'
      '((preamble "header" "preamble")
        (content "main" "content")
        (postamble "footer" "postamble"))
      org-html-metadata-timestamp-format "%Y-%m-%d")

;; Include custom css/js into the exported html document's head tag
(setq org-html-head-extra
      (concat "<link rel=\"icon\" type=\"image/x-icon\" href=\"/assets/favicon.ico\"/> \n"
              "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/css/style.css\"/> \n"
              "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/css/fonts.css\"/> \n"
              "<script type=\"text/javascript\" src=\"/assets/js/script.js\" defer></script> \n"))

(defun my-read-file (filename)
  "Return the contents of FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

;; Include custom preamble and postamble
(setq org-html-preamble (my-read-file "./source/assets/header.html")
      org-html-postamble (my-read-file "./source/assets/footer.html"))

;; Publish all the projects
(org-publish-all t)
