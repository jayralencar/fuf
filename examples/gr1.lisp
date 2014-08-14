;;; -*- Mode:Lisp; Syntax:Common-Lisp; Package:FUG5 -*-
;;; ------------------------------------------------------------
;;; File        : GR1.L
;;; Description : Simple grammar with active/passive.
;;; Author      : Michael Elhadad
;;; Created     : 20-Jun-88
;;; Modified    : 18 May 90
;;; Language    : Common Lisp
;;; Package     : FUG5
;;; ------------------------------------------------------------

(in-package "FUG5")

(defun gsetup1 ()
  "Grammar with subject-verb agreement and passive voice"
  (clear-bk-class)
  (reset-typed-features)
  (setq *u-grammar*
	'((alt top ( 
		    ;; a grammar always has the same form: an alternative
		    ;; with one branch for each constituent category.

		    ;; First branch of the alternative 
		    ;; Describe the category S.
		    ((cat s)
		     (prot ((cat np)))
		     (goal ((cat np)))
		     (verb ((cat vp)))
		     (alt (
			   ((voice active)
			    (subject {^ prot})
			    (object  {^ goal}))
			   ((voice passive)
			    (by-obj ((cat pp)
				     (prep ((lex "by") (cat prep)))
				     (np   {prot})
				     (pattern (prep np))))
			    (subject {^ goal})
			    (object  {^ by-obj}))))
		     (verb ((number {^ ^ subject number})
			    (voice  {^ ^ voice})))
		     (pattern (subject verb object)))

		    ;; Second branch: NP
		    ((cat np)
		     (n ((cat noun)
			 (number {^ ^ number})))
		     (alt (
			   ;; Proper names don't need an article
			   ((proper yes)
			    (pattern (n)))
			   ;; Common names do
			   ((proper no)
			    (pattern (det n))
			    (det ((cat article)
				  (lex "the")))))))

		    ;; Third branch: VP
		    ((cat vp)
		     (alt (
			   ((voice active)
			    (pattern (v dots))
			    (v ((cat verb) (number {^ ^ number}))))
			   ((voice passive)
			    (pattern (v1 v dots))
			    (v1 ((cat verb) (lex "be") (number {^ ^ number})))
			    (v ((cat verb) (ending past-participle)))))))

		    ;; Fourth branch: PP
		    ;; does nothing.
		    ((cat pp))
		    ;; Fifth branch: Article
		    ((cat article))
		    ((cat prep))
		    ((cat noun))
		    ((cat verb))))))

  (format t "~%GR1 installed.~%")
  (values)
)

   

