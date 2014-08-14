;;; -*- Mode:Lisp; Syntax:Common-Lisp; -*-
;;; ------------------------------------------------------------
;;; File        : GR4.L
;;; Description : Current grammar with modals added to the verb group
;;; Author      : Michael Elhadad
;;; Created     : 6-Jul-89
;;; Modified    : 10 May 90   [NEW PATHS]
;;; Language    : Common Lisp
;;; ------------------------------------------------------------

(in-package "FUG5")

(defun gsetup4 ()
  ;; No type declaration in effect.
  (clear-bk-class)
  (reset-typed-features)

  ;; This grammar takes a semantic input and maps it first into
  ;; syntactic roles.

  ;; MOOD SYSTEM:
  ;; ------------------------------------------------------------------
  ;; MOOD: finite/non-finite
  ;; FINITE: declarative/interrogative/bound/relative
  ;; NON-FINITE: imperative/present-participle/infinitive
  ;; EPISTEMIC-MODALITY: fact/inference/possible/"should"... (the modal)
  ;; DEONTIC-MODALITY: duty/authorization/(the modal - string)
  ;; INTERROGATIVE: yes-no/wh
  ;; RELATIVE-TYPE: simple/embedded/be-deleted/wh-nominal/wh-ever-nominal
  ;; SCOPE: role (value is the name of the role under scope in the relative 
  ;;        clause)

  ;; TRANSITIVITY SYSTEM:
  ;; Process-type     | Semantic roles
  ;; -----------------+-------------------------------------------------
  ;; - action         | agent, medium, benef
  ;; - mental         | processor, phenomenon
  ;; - attributive    | carrier, attribute
  ;; - equative       | identified, identifier

  ;; OPTIONAL CIRCUMSTANCIAL ROLES:
  ;; The default preposition can be overriden by specifying the corresponding
  ;; feature in the verb (cf. info needed in verb) or adding a feature prep
  ;; in the role.  The feature in the role has priority if it is given.
  ;; -------------------------------------------------------------------
  ;; Role name        | Default preposition  | Default relative pronoun 
  ;; -----------------+----------------------+--------------------------
  ;; to-loc           | to                   | where
  ;; from-loc         | from                 | where
  ;; at-loc           | at                   | where
  ;; in-loc           | in                   | where
  ;; instrument       | with                 | with (embedded)
  ;; purpose          | in order to + clause | 
  ;;                  | for + np             | for (embedded)
  ;; at-time          | at                   | when

  ;; time-relater (must be an adverb, appears first in clause)
  ;; cond-relater (must be an adverb, appears just after time - if or then)

  ;; INFORMATION NEEDED IN VERB:
  ;;      Feature     |               Possible values
  ;; -----------------+------------------------------------------------
  ;; process-class    :    action, mental, attributive, equative           
  ;; voice-class      : 	 middle, non-middle                              
  ;; transitive-class : 	 neutral, intransitive, transitive, bitransitive 
  ;; dative-prep      : 	 "to", "for"            
  ;; to-loc-prep      :    "to", ... any preposition
  ;; from-loc-prep    :    "from",... 
  ;; on-loc-prep      :    "on",...
  ;; instrument-prep  :    "with", "using" ...                         
  ;; purpose-prep     :    "for"
  ;; subject-clause   :    infinitive, present-participle, that, none
  ;; object-clause    :    infinitive, present-participle, that, none
  ;; particle         :    "off" ... (for "to take off" when particle is
  ;;                  :    mobile, when it is not mobile, lex should be 
  ;;                  :    "give up" (in one string).
  ;; preposition      :    cf Quirk 12 (not implemented yet)


  ;; SEMANTIC INFORMATION NEEDED IN NPs:
  ;; ------------------------------------------------------------------
  ;; np-type:              pronoun/common/proper                              
  ;; pronoun-type:      	 personal/question/quantified/demonstrative         
  ;; animate:           	 yes/no                                             
  ;; number:            	 plural/singular                                    
  ;; definite:          	 yes/no                                             
  ;; person:            	 first/second/third                                 
  ;; gender:            	 masculine/feminine/neuter                          
  ;; case:              	 subjective/objective/possessive/reflexive 
  ;; distance:          	 far/near                                           
  ;; countable:         	 yes/no                                             
  ;; collective:        	 yes/no                                             

  ;; CONSTITUENTS OF NPs   relevant features
  ;; ------------------------------------------------------------------
  ;; determiner:           definite/distance/demonstrative/possessive
  ;; describer:            
  ;; head:                 lex/animate/person/number/gender/case
  ;; classifier:           
  ;; qualifier:            restrictive [yes/no]
  ;; (possessive determiners are described as NPs, but without the (Cat np)
  ;; feature. For example: (determiner ((possessive yes) (np-type pronoun)...))

  (setq *u-grammar*
	'((alt
	   ;;==============================================================
	   ;; 01 CAT CLAUSE : clause --------------------------------------
	   ;;==============================================================
	   (((cat clause)
	     (alt mood (:index mood) 
		  (:demo "Deciding between mood finite and non-finite")
		  (((mood finite)
		    (non-finite none)
		    (alt finite (:index finite)
			 (:demo 
			  "Is the clause simple declarative, interrogative, relative ~
                or subordinate?")
			 (((finite declarative)
			   ;; start is a dummy constituent used only in the patterns.
			   (opt ((punctuation ((after ".")))))
			   (pattern (dots start dots)))
			  ((finite interrogative)
			   (alt (:index interrogative)
				(((interrogative yes-no))
				 ((interrogative wh)
				  (question ((cat np)
					     (np-type pronoun)
					     (pronoun-type question)))
				  (pattern (question start dots))))))
			  ((finite bound)
			   (pattern (binder start dots))
			   (binder ((cat conj)))
			   (opt binder
				((alt (:index (binder lex))
				      (((binder ((lex "that"))))
				       ((binder ((lex "whether"))))
				       ((binder ((lex "if"))))))))
			   (binder ((lex given))))
			  ((finite relative)
			   (alt (trace relative) (:index relative-type) 
				(:demo
				 "Is the relative clause simple or embedded in a PP?")
				(((relative-type simple)
				  ;; Example: the woman who lives there
				  ;;          the man whom I know
				  ;;          the reason why I came
				  ;; Simple relative is the qualifier of an NP. The NP
				  ;; is a constituent of the relative clause, as indicated
				  ;; by the scope constituent:
				  ;; if NP is medium, do (scope ((role medium))) in the relative
				  ;; clause. Scope inherits the relevant features from the 
				  ;; head of the enclosing NP.
				  (pattern (relative-marker start dots))
				  %TRACE-OFF%
				  (scope ((gap yes)
					  (cat np)
					  (lex {^ ^ ^ head lex})
					  (gender {^ ^ ^ head gender})
					  (animate {^ ^ ^ head animate})))
				  %TRACE-ON%
				  (alt relative-marker
				       (:demo "Choosing a relative pronoun.")
				       (((scope ((role at-loc))) 
					 (scope {^ at-loc-comp np})
					 (relative-marker ((cat relpro) (lex "where"))))
					((scope ((role at-time)))
					 (relative-marker ((cat rel-pro) (lex "when")))
					 (scope {^ at-time-comp np}))
					((scope ((role cause)))
					 (relative-marker ((cat relpro) (lex "why")))
					 (scope {^ cause-comp}))
					((scope ((role manner)))
					 (relative-marker ((cat relpro) (lex "how")))
					 (scope {^ manner-comp}))
					;; This is a catch-all for all other semantic roles of scope
					;; they will be realized by who/which/that
					((alt scope (:index (scope role))
					      (:demo 
					       "The pronoun is neither 'where', 'when', 'why' ~
                         or 'how.' Choose betwen 'who', 'which' and 'that'")
					      (((scope ((role agent)))
						(scope {^ agent}))
					       ((scope ((role medium)))
						(scope {^ medium}))
					       ((scope ((role benef)))
						(scope {^ benef}))
					       ((scope ((role processor)))
						(scope {^ processor}))
					       ((scope ((role phenomenon)))
						(scope {^ phenomenon}))
					       ((scope ((role carrier)))
						(scope {^ carrier}))
					       ((scope ((role attribute)))
						(scope {^ attribute}))
					       ((scope ((role identified)))
						(scope {^ identified}))
					       ((scope ((role identifier)))
						(scope {^ identifier}))))
					 (alt restrictive-relative (:index restrictive)
					      (((restrictive yes)
						(relative-marker ((cat relpro)
								  (lex "that"))))
					       ((restrictive no)
						%TRACE-OFF%
						(relative-marker ((cat np)
								  (np-type pronoun)
								  (pronoun-type relative)
								  (case {^ ^ scope case})
								  (gender {^ ^ scope gender})
								  (animate {^ ^ scope animate})))
						%TRACE-ON%)))))))
				 ((relative-type embedded)
				  ;; Example: the box in which we store the elixir
				  ;;          an experience the likes of which you have never seen
				  (pattern (prep relative-marker start dots))
				  %TRACE-OFF%
				  (prep ((cat prep)))
				  (scope ((gap yes)))
				  (relative-marker ((cat np)
						    (np-type pronoun)
						    (pronoun-type relative)
						    (case {^ ^ scope case})
						    (gender {^ ^ scope gender})
						    (animate {^ ^ scope animate})))
				  %TRACE-ON%
				  (alt scope-embedded (:index (scope role))
				       (:demo "This is an embedded relative.  What ~
                                   preposition must be used?")
				       (((scope ((role instrument)))
					 (opt ((prep ((lex "with")))))
					 (scope {^ instrument-comp}))
					((scope ((role to-loc)))
					 (opt ((prep ((lex "to")))))
					 (scope {^ to-loc-comp}))
					((scope ((role from-loc)))
					 (opt ((prep ((lex "from")))))
					 (scope {^ from-loc-comp}))
					((scope ((role purpose)))
					 (opt ((prep ((lex "for")))))
					 (scope {^ purpose-comp})))))
				 ((relative-type be-deleted))
				 ;; Example: Goldwater /who was/ crushed by his defeat
				 ;;          the team /that is/ expected to win
				 ;;          an enchanting island /that is/ waiting to be seen
				 ((relative-type wh-nominal))
				 ;; Example: They were amazed at which one they chose
				 ;;          I couldn't believe how many people understood
				 ;;          What they did next was surprising
				 ((relative-type wh-ever-nominal))))))))
		   ;; Example: Whoever did it will be sorry
		   ((mood non-finite)
		    (finite none)
		    (alt non-finite (:index non-finite)
			 (:demo "Is the clause imperative, present-participle ~
                             or infinitive?")
			 (((non-finite imperative)
			   (opt ((punctuation ((after ".")))))
			   (epistemic-modality none)
			   (deontic-modality none)
			   (verb ((ending root))))
			  ((non-finite present-participle)
			   (verb ((ending present-participle)))
			   (epistemic-modality none)
			   (deontic-modality none))
			  ((non-finite infinitive)
			   (epistemic-modality none)
			   (deontic-modality none)
			   (verb ((ending infinitive)))))))))

	     (alt process (:index process-type)
		  (:demo "Is the process an action, mental, attributive ~
                          or equative?")
		  ;; Process-type: action, mental, or relation
		  ;; -----------------------------------------

		  ;; Process 1: Action --> actions, events, natural phenomena
		  ;; So far only actions done.
		  ;; inherent cases    --> agent, medium, benef.
		  ;; all are optional, but at least one of medium or agent
		  ;; must be present.
		  ;; this will be dealt with in the voice alternation.

		  ;; ALLOW CONJUNCTIONS IN ACTION ROLES
		  (((process-type action)
		    (alt agent-cat 
			 (:demo "Is the agent an object or a process?")
			 (((agent ((cat np)
				   %TRACE-OFF%
				   (alt (((lex given))
					 ((head given))
					 ((np-type given) (np-type pronoun))
					 ((gap given))))
				   %TRACE-ON%)))
			  ((agent none))
			  ((agent ((cat given)
				   (cat clause))))))
		    (alt medium-cat
			 (:demo "Is the medium an object or a process?")
			 (((medium ((cat np)
				    %TRACE-OFF%
				    (alt (((lex given))
					  ((head given))
					  ((np-type given) (np-type pronoun))
					  ((gap given))))
				    %TRACE-ON%)))
			  ((medium none))
			  ((medium ((cat given)
				    (cat clause))))))
		    (alt benef-cat
			 (:demo "Is there a benef in the process?")
			 (((benef none)) ;; no clausal benef
			  ((benef ((cat np) ;; couldn't find example
				   %TRACE-OFF%
				   (alt (((lex given))
					 ((head given))
					 ((np-type given) (np-type pronoun))
					 ((gap given))))
				   %TRACE-ON%)))))

		    (verb ((process-class action)
			   (lex given)))) ;there must be a verb given

		   ;; Process 2: mental --> perception, reaction, cognition, verbalization
		   ;; inherent cases    --> processor, phenomenon
		   ;; processor is required, phenomenon is optional.
		   ((process-type mental)
		    (verb ((process-class mental)
			   (lex given)))
		    (alt processor-cat
			 (:demo "Is there a processor in the process?")
			 (((processor ((cat np) (animate yes)
				       %TRACE-OFF%
				       (alt (((lex given))
					     ((head given))
					     ((np-type given) (np-type pronoun))
					     ((gap given))))
				       %TRACE-ON%)))
			  ((processor none))))
		    (alt phenomenon-cat
			 (:demo "Is the phenomenon an object or a process?")
			 (((phenomenon none))
			  ((phenomenon ((cat np)
					%TRACE-OFF%
					(alt (((lex given))
					      ((head given))
					      ((np-type given) (np-type pronoun))
					      ((gap given))))
					%TRACE-ON%)))
			  ((phenomenon ((cat given)
					(cat clause)))))))

		   ;; Process 3: relation --> equative, attributive
		   ;; there need not be a verb, it will be determined by the
		   ;; epistemic modality features among the possible copula.
		   ((process-type attributive)
		    (verb ((process-class attributive)))
		    ;; so far all we do if the verb is not given use "be"
		    ;; later use modality...
		    (opt be-attributive
			 ((verb ((lex "be")
				 (subject-clause infinitive)
				 (object-clause none)
				 (voice-class non-middle)
				 (transitive-class neutral)))))
		    ;; inherent cases     --> carrier, attribute
		    (alt carrier-cat
			 (:demo "Is the carrier an object or a process?")
			 (((carrier ((cat np)
				     (alt (((lex given))
					   ((head given))
					   ((np-type given) (np-type pronoun))
					   ((gap given)))))))
			  ((carrier none))
			  ((carrier ((cat given)
				     (cat clause))))))
		    ;; attribute can be a property or a class
		    ;; like in "John is a teacher" or "John is happy".
		    (alt attribute-cat (:index (attribute cat))
			 (:demo "Is the attribute an object or an attribute?")
			 (((attribute ((cat adj)
				       (lex given))))
			  ((attribute ((cat list)
				       (common ((cat ((alt (np adj)))))))))
			  ((attribute ((cat np) 
				       %TRACE-OFF%
				       (alt (((lex given))
					     ((head given))
					     ((np-type given) (np-type pronoun))))
				       %TRACE-ON%))))))


		   ((process-type equative)
		    ;; inherent cases    --> identified, identifier
		    ;; both cases have the same definite feature
		    ;; and are required. 
		    ;; "A book is an object" or "The president is the chief"
		    (verb ((process-class equative)))
		    (opt verb-be-equative
			 ((verb ((lex "be")
				 (voice-class non-middle)
				 (subject-clause that)
				 (object-clause present-participle)
				 (transitive-class neutral)))))
		    (alt identified-cat
			 (:demo "Is the identified an object or a process?")
			 (((identified ((cat np)
					%TRACE-OFF%
					(alt (((lex given))
					      ((head given))
					      ((np-type given) (np-type pronoun))
					      ((gap given))))
					%TRACE-ON%)))
			  ((identified none))
			  ((identified ((cat given)
					(cat clause))))))
		    (identifier (
				 (alt identifier-cat
				      (:demo "Is the identifier an object or ~
                                       a process?")
				      (((cat np)
					%TRACE-OFF%
					(alt (((lex given))
					      ((head given))
					      ((np-type given) (np-type pronoun))
					      ((gap given))))
					%TRACE-ON%)
				       ((cat given)
					(cat clause))
				       ((cat list)
					(common ((cat np)))))))))))

	     ;; Voice choice --> operative, middle, receptive.
	     ;; Operative =~ active
	     ;; Receptive =~ passive
	     ;; Middle    = sentences with only one participant ("the sun shines")
	     ;; Choice middle/non-middle is based on verb classification
	     ;; it is also based on the interaction verb/participant but we don't
	     ;; do that yet.
	     ;; Choice receptive/operative is based on focus (using pattern).
	     ;; The voice alternation does the mapping semantic -> syntactic roles
	     (alt voice (:index (verb voice-class))
		  (:demo "Is the verb middle or non-middle?")
		  (((verb ((voice-class middle)))
		    (voice middle)
					; We must have only one participant, the medium that is the subject.
		    (alt (:index process-type) 
			 ;; main case is the subject.
			 ;; cannot have a middle verb with process-type relation.
			 (((process-type action)
			   ;; (agent none)            ;; ERGATIVE CONSTRUCT to work out.
			   ;; agent make medium verb.
			   (benef none)
			   (subject {^ medium}))
			  ((process-type mental) ;; ??? Are there mental/middle
			   (subject {^ processor}))))
		    (object none)
		    (iobject none))
		   ((verb ((voice-class non-middle)))
		    (alt non-middle-voice (:index voice)
			 (:demo "Is the clause passive or active? This ~
                             determines the mapping deep to surface roles")
			 (((voice operative)
			   (verb ((voice active)))
			   (alt (:index process-type)
				(((process-type action)
				  (subject {^ agent})
				  (object {^ medium})
				  (iobject {^ benef}))
				 ((process-type mental)
				  (subject {^ processor})
				  (object  {^ phenomenon})
				  (iobject none))
				 ((process-type equative)
				  (subject {^ identified})
				  (object {^ identifier})
				  (iobject none))
				 ((process-type attributive)
				  (subject {^ carrier})
				  (object  {^ attribute})
				  (iobject none)))))
			  ((voice receptive)
			   ;; Warning: a receptive is not always translated into a
			   ;; passive verb!!!: "this string won't tie" (no actor).
			   (alt (index process-type)
				(((process-type action)
				  (verb ((voice passive)))
				  (alt 
				   ;; Is there an explicit prot?
				   ;; well, actually should distinguish between
				   ;; "the door opened" and "the door was opened".
				   (((agent none)
				     (by-obj none))
				    ((agent ((gap given) (gap yes)))
				     (by-obj none))
				    ((agent given)
				     (by-obj ((np {^ ^ agent}))))))
				  (alt
				   ;; subject is either benef or medium
				   ;; "A book is given to mary by john"
				   ;; "Mary is given a book by John"
				   (((subject {^ medium})
				     (iobject {^ benef})
				     (object none))
				    ((subject {^ benef})
				     (object  {^ medium})
				     (iobject none)))))
				 ((process-type mental)
				  (verb ((voice passive)))
				  (subject {^ phenomenon})
				  (alt
				   ;; is there an explicit processor?
				   (((processor ((lex none))))
				    ((processor ((lex given)))
				     (by-obj ((np {^ ^ processor}))))))
				  (iobject none))
				 ;; cannot have an attributive process in receptive voice.
				 ((process-type equative)
				  (subject {^ identifier})
				  (object  {^ identified})
				  (verb ((voice active)))
				  (iobject none))))))))))

	     %AFTER-VOICE%
	     (control (control-demo "*****I = ~s~%~%" *input*))
	     %AFTER-VOICE%

	     ;; Now take care of special treatment of subject
	     ;; clauses (this is the right time because the subject is now bound).

	     (alt subject-mood
		  (:index mood) 
		  (:demo "Is a subject required or does it need a special treatment?")
		  (((mood finite)
		    (subject given))
		   ((mood non-finite)
		    (alt (:index non-finite)
			 (((non-finite infinitive)
			   (opt INF-SUB 
				((subject given)
				 (subject ((cat np) (case objective)))))
			   (opt ((case given) (case purposive) (pattern (in-order dots))))
			   ;; When the clause is subject or purpose, and there is a subject,
			   ;; use a FOR-clause as in "for her to do it is a bold statement"
			   (alt keep-for
				(:demo "Should we use a for in front of the subject?")
				(((keep-for yes)
				  (case ((alt (subjective purposive))))
				  (subject given)
				  (pattern (dots for start dots))
				  (for ((cat conj) (lex "for"))))
				 ((keep-for no)))))
			  ((non-finite present-participle)
			   ;; subject is optional or in possessive form
			   (alt 
			    (((subject given)
			      (subject ((cat np)
					(case possessive))))
			     ((subject none))
			     ((subject ((gap yes)))))))
			  ((non-finite imperative)
			   ;; subject is optional in realization
			   (alt (((subject none))
				 ((subject ((gap yes))))))))))))

	     ;; Syntactic categories of subject/object are compatible with verb?
	     ;; This depends on particular verb, information we will get from the
	     ;; lexicon. So far, we check whether subject-clause and object-clause
	     ;; are ok. If you had disjunctions allowed in the input, life would be
	     ;; easier (we would put: subject-cat (alt <possible-values>)) in the 
	     ;; lexicon. We could also do it with a (cat member). And we can also
	     ;; do it by using a different feature for each acceptable cat.
	     (alt subject
		  (((subject ((cat given) (cat np))))
		   ((subject none))
		   ((alt subject-clause
			 (:index (verb subject-clause))
			 (:demo "For clausal subjects, what type of clause ~
                           must be used?")
			 (((verb ((subject-clause infinitive)))
			   (subject ((cat clause)
				     (mood non-finite)
				     (non-finite infinitive))))
			  ((verb ((subject-clause present-participle)))
			   (subject ((cat clause)
				     (mood non-finite)
				     (non-finite present-participle))))
			  ((verb ((subject-clause that)))
			   (subject ((cat clause)
				     (mood finite)
				     (finite bound)
				     (binder ((lex "that")))))))))))

      
	     (alt object
		  (((object ((cat np))))
		   ((object none))
		   ((object ((cat adj))))
		   ((object ((cat list) (common ((cat ((alt (np adj)))))))))
		   ((alt object-clause
			 (:index (verb object-clause))
			 (:demo "For clausal objects, what type of clause ~
                           must be used?")	  
			 (((verb ((object-clause infinitive)))
			   (object ((cat clause)
				    (mood non-finite)
				    (non-finite infinitive))))
			  ((verb ((object-clause present-participle)))
			   (object ((cat clause)
				    (mood non-finite)
				    (non-finite present-participle))))
			  ((verb ((object-clause that)))
			   (object ((cat clause)
				    (mood finite)
				    (finite bound)
				    (binder ((lex "that")))))))))))

	     ;; Number of inherent participants to the process besides the subject.
	     ;; Based on verb classification:
	     ;; Neutral: 1 or 2 participants
	     ;; Intransitive: 1 participant
	     ;; Transitive:   2 participants
	     ;; Bitransitive: 3 participants
	     (alt transitivity (:index (verb transitive-class))
		  (:demo "How many roles can be used with this verb?")
		  (((verb ((transitive-class intransitive)))
		    (object none)
		    (iobject none)
		    (dative none))
		   ((verb ((transitive-class transitive)))
		    (iobject none)
		    (dative none))
		   ((verb ((transitive-class neutral)))
		    (iobject none)
		    (dative none))
		   ((verb ((transitive-class bitransitive))))))

	     ;; OPTIONAL CASES:
	     ;; These cases can occur with all process-types.
	     ;; They handle "circumstances".
	     ;; All have the same structure.
	     ;; Order should be studied with care. I have now a standard order.
	     ;; All roles are mapped to corresponding syntactic complements.

	     (alt to-loc
		  (:demo "Is there a to-loc role?")
		  ((%TRACE-OFF%
		    (control (control-demo "No to-loc"))
		    %TRACE-ON%
		    (to-loc none))
		   ((to-loc given)
		    %TRACE-OFF%
		    (control (control-demo "To-loc is here."))
		    ;; get prep from role if given, otw from verb, otw default.
		    (opt ((to-loc ((prep given)))
			  (to-loc-comp ((prep ((lex {^ ^ ^ to-loc prep})))))))
		    (opt ((verb ((to-loc-prep given)))
			  (to-loc-comp ((prep ((lex {^ ^ ^ verb to-loc-prep})))))))
		    (to-loc-comp ((cat pp)
				  (opt ((prep ((lex "to")))))
				  (np ((cat np)
				       (definite {^ ^ ^ to-loc definite})
				       (np-type  {^ ^ ^ to-loc np-type})
				       (pronoun-type {^ ^ ^ to-loc pronoun-type})
				       (animate {^ ^ ^ to-loc animate})
				       (number {^ ^ ^ to-loc number})
				       (person {^ ^ ^ to-loc person})
				       (gender {^ ^ ^ to-loc gender})
				       (distance {^ ^ ^ to-loc distance})
				       (countable {^ ^ ^ to-loc countable})
				       (determiner {^ ^ ^ to-loc determiner})
				       (describer {^ ^ ^ to-loc describer})
				       (head {^ ^ ^ to-loc head})
				       (classifier {^ ^ ^ to-loc classifier})
				       (qualifier {^ ^ ^ to-loc qualifier})
				       (lex      {^ ^ ^ to-loc lex})))))
		    %TRACE-ON%)))
      
	     (alt from-loc (:demo "Is there a from-loc role?")
		  (((from-loc none)
		    (control "No from-loc"))
		   ((from-loc given)
		    %TRACE-OFF%
		    (control (control-demo "From-loc is here"))
		    (opt ((from-loc ((prep given)))
			  (from-loc-comp ((prep ((lex {^ ^ ^ from-loc prep})))))))
		    (opt ((verb ((from-loc-prep given)))
			  (from-loc-comp 
			   ((prep ((lex {^ ^ ^ verb from-loc-prep})))))))
		    (from-loc-comp ((cat pp)
				    (opt ((prep ((lex "from")))))
				    (np ((cat np)
					 (definite {^ ^ ^ from-loc definite})
					 (np-type  {^ ^ ^ from-loc np-type})
					 (pronoun-type {^ ^ ^ from-loc pronoun-type})
					 (animate {^ ^ ^ from-loc animate})
					 (number {^ ^ ^ from-loc number})
					 (person {^ ^ ^ from-loc person})
					 (gender {^ ^ ^ from-loc gender})
					 (distance {^ ^ ^ from-loc distance})
					 (countable {^ ^ ^ from-loc countable})
					 (determiner {^ ^ ^ from-loc determiner})
					 (describer {^ ^ ^ from-loc describer})
					 (head {^ ^ ^ from-loc head})
					 (classifier {^ ^ ^ from-loc classifier})
					 (qualifier {^ ^ ^ from-loc qualifier})
					 (lex      {^ ^ ^ from-loc lex})))))
		    %TRACE-ON%)))
      
	     (alt on-loc (:demo "Is there an on-loc role?")
		  (((on-loc none))
		   ((on-loc given)
		    (opt ((on-loc ((prep given)))
			  (on-loc-comp ((prep ((lex {^ ^ ^ on-loc prep})))))))
		    (opt ((verb ((on-loc-prep given)))
			  (on-loc-comp ((prep ((lex {^ ^ ^ verb on-loc-prep})))))))
		    (on-loc-comp ((cat pp)
				  (opt ((prep ((lex "on")))))
				  (np ((cat np)
				       (definite {^ ^ ^ on-loc definite})
				       (np-type  {^ ^ ^ on-loc np-type})
				       (pronoun-type {^ ^ ^ on-loc pronoun-type})
				       (animate {^ ^ ^ on-loc animate})
				       (number {^ ^ ^ on-loc number})
				       (person {^ ^ ^ on-loc person})
				       (gender {^ ^ ^ on-loc gender})
				       (distance {^ ^ ^ on-loc distance})
				       (countable {^ ^ ^ on-loc countable})
				       (determiner {^ ^ ^ on-loc determiner})
				       (describer {^ ^ ^ on-loc describer})
				       (head {^ ^ ^ on-loc head})
				       (classifier {^ ^ ^ on-loc classifier})
				       (qualifier {^ ^ ^ on-loc qualifier})
				       (lex      {^ ^ ^ on-loc lex}))))))))
      
	     (alt in-loc (:demo "Is there an in-loc role?")
		  (((in-loc none))
		   ((in-loc given)
		    ;; get prep from role if given, otw from verb, otw default.
		    (opt ((in-loc ((prep given)))
			  (in-loc-comp ((prep ((lex {^ ^ ^ in-loc prep})))))))
		    (opt ((verb ((in-loc-prep given)))
			  (in-loc-comp ((prep ((lex {^ ^ ^ verb in-loc-prep})))))))
		    (in-loc-comp ((cat pp)
				  (opt ((prep ((lex "in")))))
				  (np ((cat np)
				       (definite {^ ^ ^ in-loc definite})
				       (np-type  {^ ^ ^ in-loc np-type})
				       (pronoun-type {^ ^ ^ in-loc pronoun-type})
				       (animate {^ ^ ^ in-loc animate})
				       (number {^ ^ ^ in-loc number})
				       (person {^ ^ ^ in-loc person})
				       (gender {^ ^ ^ in-loc gender})
				       (distance {^ ^ ^ in-loc distance})
				       (countable {^ ^ ^ in-loc countable})
				       (determiner {^ ^ ^ in-loc determiner})
				       (describer {^ ^ ^ in-loc describer})
				       (head {^ ^ ^ in-loc head})
				       (classifier {^ ^ ^ in-loc classifier})
				       (qualifier {^ ^ ^ in-loc qualifier})
				       (lex      {^ ^ ^ in-loc lex}))))))))
      
	     (alt instrument (:demo "Is there an instrument role?")
		  (((instrument none))
		   ((instrument given)
		    (opt ((instrument ((prep given)))
			  (instrument-comp ((prep ((lex {^ ^ ^ instrument prep})))))))
		    (opt 
		     ((verb ((instrument-prep given)))
		      (instrument-comp 
		       ((prep ((lex {^ ^ ^ verb instrument-prep})))))))
		    (instrument-comp
		     ((cat pp)
		      (opt ((prep ((lex "with")))))
		      (np ((cat np)
			   (definite {^ ^ ^ instrument definite})
			   (np-type  {^ ^ ^ instrument np-type})
			   (pronoun-type {^ ^ ^ instrument pronoun-type})
			   (animate {^ ^ ^ instrument animate})
			   (number {^ ^ ^ instrument number})
			   (person {^ ^ ^ instrument person})
			   (gender {^ ^ ^ instrument gender})
			   (distance {^ ^ ^ instrument distance})
			   (countable {^ ^ ^ instrument countable})
			   (determiner {^ ^ ^ instrument determiner})
			   (describer {^ ^ ^ instrument describer})
			   (head {^ ^ ^ instrument head})
			   (classifier {^ ^ ^ instrument classifier})
			   (qualifier {^ ^ ^ instrument qualifier})
			   (lex      {^ ^ ^ instrument lex}))))))))
      
	     (alt purpose (:demo "Is there a purpose role?")
		  (((purpose none))
		   ((purpose given)
		    (purpose ((cat clause)
			      (mood non-finite)
			      (non-finite infinitive)
			      (case purposive)
			      (opt ((in-order ((lex "in order") (cat conj)))))
			      (punctuation ((after ",")))))
		    (alt (((pattern (purpose dots)))
			  ((pattern (dots purpose))))))
		   ((purpose given)
		    (purpose ((cat np)))
		    (opt ((purpose ((prep given)))
			  (purpose-comp ((prep ((lex {^ ^ ^ purpose prep})))))))
		    (opt 
		     ((verb ((purpose-prep given)))
		      (purpose-comp 
		       ((prep ((lex {^ ^ ^ verb purpose-prep})))))))
		    (purpose-comp 
		     ((cat pp)
		      (opt ((prep ((lex "for")))))
		      %TRACE-OFF%
		      (np ((cat np)
			   (definite {^ ^ ^ purpose definite})
			   (np-type  {^ ^ ^ purpose np-type})
			   (pronoun-type {^ ^ ^ purpose pronoun-type})
			   (animate {^ ^ ^ purpose animate})
			   (number {^ ^ ^ purpose number})
			   (person {^ ^ ^ purpose person})
			   (gender {^ ^ ^ purpose gender})
			   (distance {^ ^ ^ purpose distance})
			   (countable {^ ^ ^ purpose countable})
			   (determiner {^ ^ ^ purpose determiner})
			   (describer {^ ^ ^ purpose describer})
			   (head {^ ^ ^ purpose head})
			   (classifier {^ ^ ^ purpose classifier})
			   (qualifier {^ ^ ^ purpose qualifier})
			   (lex      {^ ^ ^ purpose lex})))
		      %TRACE-ON%)))))
      
	     ;; All the possible time roles under one at-time plus a time-type
	     ;; feature sub-categorizing it.  This means I can have only one time
	     ;; role per clause.
	     ;; The list of time-type is given in Quirk 11.27
	     ;; Ex: in the afternoon, later, when I have time, last Thursday
	     (alt at-time
		  (:demo "Is there an at-time role?")
		  (((at-time none))
		   ((at-time given)
		    (alt at-time (:index (at-time cat))
			 (((at-time ((cat adv)))
			   (time-comp {^ at-time}))
			  ((at-time  ((cat clause)
				      (mood finite)
				      (finite bound)
				      (binder ((lex {^ ^ time-type})))
				      (time-type ((alt ("after" "as" "before"
								"once" "since" "until" "when"
								"while" "now that"))))))
			   (time-comp {^ at-time}))
			  ((at-time ((cat np)))
			   (time-type ((alt ("at" "on" "in" "for" "before" "after"
						  "since" "until"))))
			   (time-comp ((cat pp)
				       (prep ((lex {^ ^ ^ at-time time-type})))
				       (np ((cat np)
					    (number   {^ ^ ^ at-time number})
					    (definite {^ ^ ^ at-time definite})
					    (np-type  {^ ^ ^ at-time np-type})
					    (lex      {^ ^ ^ at-time lex})))))))))))

	     (alt time-relater (:demo "Is there a time-relater?")
		  (((time-relater none))
		   ((time-relater given)
		    (time-relater ((cat adv)
				   (punctuation ((after ",")))))
		    (pattern (time-relater dots)))))

	     (alt cond-relater (:demo "Is there a cond-relater?")
		  (((cond-relater none))
		   ((cond-relater given)
		    (cond-relater ((cat adv)))
		    (pattern (time-relater cond-relater dots)))))



	     ;; General things: arrange syntactic roles together
	     ;; and do the agreements.
	     ;; The patterns are here of course.
      
	     ;; Focus first (change when add modifiers)
	     ;; (pattern ((* focus) dots))
	     %focus%
	     (focus {^ subject})
	     (control (control-demo "*****I = ~s~%~%" *input*))
	     %focus%

	     ;; Number and person agreement
	     (verb ((cat verb-group)
		    (epistemic-modality {^ ^ epistemic-modality})
		    (deontic-modality {^ ^ deontic-modality})
		    (person {^ ^ subject person})
		    (number {^ ^ subject number})))
      
	     ;; Arrange order of complements
	     ;; start is a dummy constituent used only for the ordering
	     ;; constraints
	     ;; particle is for verbs like "take off"
	     (alt particle (:demo "Does the verb have a particle?")
		  (((verb ((particle none))))
		   ((verb ((particle given)))
		    (particle ((cat adv)
			       (lex {^ ^ verb particle}))))))
	     (alt verb-voice (:index (verb voice))
		  (:demo "Is the clause active or passive? This will ~
                          determine the form of the verb.")
		  ;; VERB VOICE ACTIVE
		  (((verb ((voice active)))
		    (by-obj none)
		    (alt (((verb ((transitive-class bitransitive) 
				  (dative-prep none)))
			   (particle none)
			   (pattern (dots start subject verb iobject object dots)))
			  ((verb ((transitive-class bitransitive) 
				  (dative-prep given)))
			   (dative ((cat pp) 
				    (prep ((lex {^ ^ ^ verb dative-prep})))
				    (np {^ ^ iobject})))
			   (pattern (dots start subject verb object particle 
					  dative dots)))
			  ((pattern (dots start subject verb object particle dots))))))
		   ;; VERB VOICE PASSIVE
		   ((verb ((voice passive)))
		    (pattern (dots start subject verb object particle by-obj dative dots))
		    (by-obj ((alt (none
				   ((cat pp)
				    (np given)
				    (np   ((case objective)))
				    (prep ((lex "by"))))))))
		    (opt ((iobject given)
			  (verb ((dative-prep given)))
			  (dative ((cat pp)
				   (prep ((lex {^ ^ ^ verb dative-prep})))
				   (np {^ ^ iobject}))))))))

	     ;; Case assignment
	     (opt ((subject ((case subjective)))))
	     (opt ((object  ((case objective)))))
	     (opt ((iobject ((case objective)))))

	     ;; Place optional roles
	     (pattern (dots start dots verb dots time-comp from-loc-comp to-loc-comp
			    on-loc-comp in-loc-comp instrument-comp 
			    purpose-comp dots))) 

	    ;;==============================================================
	    ;; 02 CAT VERB-GROUP -------------------------------------------
	    ;;==============================================================
	    ;; No treatment of auxiliary yet
	    ((cat verb-group)
	     (v ((person {^ ^ person})
		 (number {^ ^ number})
		 (tense  {^ ^ tense})
		 (ending {^ ^ ending})))
	     ;; v carries the agreement features
	     ;; v1 and v2 are optional parts
	     ;; for groups like "must be done"

	     (alt (((epistemic-modality none)
		    (deontic-modality none))
		   ((epistemic-modality given)
		    (deontic-modality none))
		   ((deontic-modality given)
		    (epistemic-modality none))))
	     (alt modality
		  (:demo "What modality is used with the verb?")
		  (((epistemic-modality none)
		    (deontic-modality none)
		    %TRACE-OFF%
		    (control (control-demo "No modality in this clause"))
		    %TRACE-ON%
		    (v ((cat verb))))
		   ((epistemic-modality fact)
		    (v ((cat verb))))
		   ((epistemic-modality inference)
		    (v ((lex "must")
			(cat modal)))
		    (v1 ((ending root))))
		   ((epistemic-modality possible)
		    (v ((lex "can")
			(cat modal)))
		    (v1 ((ending root))))
		   ((deontic-modality duty)
		    (v ((lex "must")
			(cat modal)))
		    (v1 ((ending root))))
		   ((deontic-modality authorisation)
		    (v ((lex "may")
			(cat modal)))
		    (v1 ((ending root))))
		   ((control (string #@{^ epistemic-modality}))
		    (v ((lex {^ ^ epistemic-modality})
			(cat modal)))
		    (v1 ((ending root))))
		   ((control (string #@{^ deontic-modality}))
		    (v ((lex {^ ^ deontic-modality})
			(cat modal)))
		    (v1 ((ending root))))))
	    
	     (alt voice-verb (:index voice)
		  (:demo "Is the verb active or passive?")
		  (((voice active)
		    (alt (((epistemic-modality given)
			   (v1 ((cat verb) (lex {^ ^ lex})))
			   (v2 none))
			  ((deontic-modality given)
			   (v1 ((cat verb) (lex {^ ^ lex})))
			   (v2 none))
			  ((epistemic-modality none)
			   (deontic-modality none)
			   (v ((lex {^ ^ lex})))))))
		   ((voice passive)
		    (alt (((alt (((epistemic-modality given))
				 ((deontic-modality given))))
			   (v1 ((cat verb) (lex "be")))
			   (v2 ((cat verb)
				(lex {^ ^ lex})
				(ending past-participle))))
			  ((epistemic-modality none)
			   (deontic-modality none)
			   (v ((lex "be")))
			   (v1 ((cat verb) 
				(lex {^ ^ lex}) 
				(ending past-participle)))))))))
	     (pattern (v v1 v2)))
     
	    ;;==============================================================
	    ;; 03 CAT NP ---------------------------------------------------
	    ;;==============================================================
	    ;; Prototypical sequence: determiner modifiers head qualifiers
	    ;; determiner = (pre-determiner determiner ordinal cardinal)
	    ;; modifiers  = (describer classifier)
	    ;; qualifiers = (restrictive non-restrictive possessive-marker)
	    ;; We expect in the input at the top-level constituents:
	    ;; - definite yes/no (default is yes).
	    ;; - a lex that will be interpreted as the lex of the head.
	    ;; - describer: an embedded list of describers.
	    ;; - classifier: an embedded list of classifiers.
	    ;; - qualifiers: an embedded list of qualifiers.
     
	    ((cat np)
	     ;; GENERAL NP =================================================
					; np inherits major features from head and definite from determiner
	     (pattern (dots head dots))
	     (head ((lex {^ ^ lex})
		    (number {^ ^ number})
		    (animate {^ ^ animate})
		    (gender {^ ^ gender})
		    (np-type {^ ^ np-type})))
      
	     ;; NP-TYPE: Pronouns, common, proper =========================
	     (alt np-type 
		  (:index np-type)
		  (:demo "Is this a common noun, a pronoun or a proper noun?")
		  ;; COMMON NOUNS -------------------------------------------
		  ;; Only common nouns can have determiners.
		  (((np-type common)
		    (head ((cat noun)
			   (a-an {^ ^ a-an})
			   (lex given)))
		    (person third)
		    (alt (:index countable)
			 (((countable yes))
			  ((countable no)
			   (definite no))))
		    (pattern (determiner dots))
		    (determiner ((cat det)
				 (definite  {^ ^ definite})
				 (countable {^ ^ countable})
				 (distance  {^ ^ distance}))))
	
		   ;; PRONOUNS ------------------------------------------------
		   ((np-type pronoun)
		    ;; pronouns allow no classifier, no determiner, 
		    ;; all except quantified have no describer.
		    ;; can have qualifiers
		    (classifier none)
		    (determiner none)
		    (head ((cat pronoun)
			   (case {^ ^ case})
			   (number {^ ^ number})
			   (animate {^ ^ animate})
			   (pronoun-type {^ ^ pronoun-type})))
		    (pattern (head dots))
		    ;; Pronoun-type: personal, demonstrative, question, quantified
		    ;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		    (alt pronoun-type 
			 (:index pronoun-type)
			 (:demo "Is this a personal, relative, demonstrative, question ~
                          or quantified pronoun?")
			 (((pronoun-type personal)
			   ;; are gender and person specific, default is third masculine.
			   (alt %gender% (:index gender)
				(((gender neuter) (animate no))
				 ((gender masculine) (animate yes))
				 ((gender feminine) (animate yes))))
			   (alt (:index person)
				(((person third))
				 ((person first))
				 ((person second))))
			   (head ((gender {^ ^ gender})
				  (person {^ ^ person})))
			   (definite yes)
			   (describer none))
			  ((pronoun-type relative))
			  ((pronoun-type demonstrative)
			   (definite yes)
			   (person third)
			   (describer none)
			   (head ((distance {^ ^ distance})))
			   (alt (:index distance)
				(((distance far))
				 ((distance near)))))
			  ((pronoun-type question)
			   (definite no)
			   (person third)
			   (describer none))
			  ;; - describers come after head: "something green"
			  ((pronoun-type quantified)
			   (definite no)
			   (person third)
			   (alt (((describer none))
				 ((pattern (head describer dots))))))
			  ))
		    ;; Case: subjective, objective, possessive, reflexive
		    ;; - - - - - - - - - - - - - - - - - - - - - - - - -
		    (alt pronoun-case 
			 (:demo "Is the pronoun subject, object, possessive ~
                          or reflexive?")
			 (((case given)
			   (alt pron-case (:index case)
				(((case subjective))
				 ((case objective))
				 ((case possessive))
				 ((case reflexive)))))
			  ((case subjective)))))


		   ;; Proper nouns -------------------------------------------
		   ((np-type proper)
		    (head ((cat noun)))
		    (person third)
		    (pattern (head))
		    (definite yes)
		    (determiner none)
		    (describer none)
		    (classifier none)
		    (qualifier none))))

	     ;; NUMBER ====================================================
	     (alt number (:index number)
		  (((number singular))
		   ((number plural))))

	     ;; DESCRIBER =================================================
	     (alt describer
		  (:demo "Is there a describer?")
		  (((describer none))
		   ((describer given)
		    (pattern (dots describer dots head dots))
		    (alt
		     (((describer ((cat adj))))
		      ((describer ((cat verb)
				   (ending past-participle)
				   (modifier-type objective))))
		      ((describer ((cat verb)
				   (ending present-participle)
				   (modifier-type subjective)))))))))

	     ;; CLASSIFIER =================================================
	     (alt classifier 
		  (:demo "Is there a classifier?")
		  (((classifier none))
		   ((classifier given)
		    (pattern (dots classifier head dots))
		    (alt (:index (classifier cat))
			 (((classifier ((cat noun))))
			  ((classifier ((cat verb)
					(ending present-participle)
					(modifier-type subjective)))))))))

	     ;; QUALIFIER ==================================================
	     (alt qualifier
		  (:demo "Is there a qualifier? Is it an apposition, a PP or ~
                      a relative clause?")
		  (((qualifier none))
		   ((qualifier given)
		    (pattern (dots head qualifier))
		    (alt qualifier-cat (:index (qualifier cat))
			 (((qualifier ((cat pp)
				       (restrictive yes)))
			   ;; send features of qualifier just to np of pp.
			   ;; default prep is "of".
			   (opt ((qualifier ((prep ((lex "of")))))))
			   (qualifier ((np ((head {^ ^ head})
					    (lex  {^ ^ lex})
					    (definite {^ ^ definite})
					    (np-type {^ ^ np-type})
					    (pronoun-type {^ ^ pronoun-type})
					    (animate {^ ^ animate})
					    (number {^ ^ number})
					    (person {^ ^ person})
					    (gender {^ ^ gender})
					    (case {^ ^ case})
					    (distance {^ ^ distance}))))))
			  ((qualifier ((cat np)))
			   (alt (:index (qualifier restrictive))
				(((qualifier ((restrictive yes))))
				 ((qualifier ((restrictive no)
					      (punctuation ((before ",")
							    (after ",")))))))))
			  ((qualifier ((cat clause)
				       (mood finite)
				       (finite relative)))))))))
		  

	     ;; CATAPHORA ==================================================
	     (opt 
	      ((ref-type given)
	       (ref-type immediate-cataphora)
	       (pattern (dots referred))
	       (referred ((cat ((alt (list np))))
			  (punctuation ((before ":")))))))


	     ;; POSSESSIVE MARKER ==========================================
	     (alt np-case
		  (:demo "Is this a possessive NP?")
		  (((case none))
		   ((case given)
		    (case possessive)
		    (qualifier none)
		    (head ((feature possessive))))
		   ((case given))))
	     )

	    ;; ==============================================================
	    ;; 04 CAT LIST : for coordinated constituents -------------------
	    ;; ==============================================================
	    ;; Lists have 3 main features:
	    ;; common: all the features common to all conjuncts
	    ;; distinct: a list of features in car/cdr form
	    ;; conjunction: the conjunction of coordination to use.
	    ;; NOTE: don't deal with ellipsis of common parts.
	    ;; NOTE: ONLY ALLOW LISTS OF CLAUSES AND NPS.
	    ;;       if you want other cats, change the alts here 
	    ;;       (3 identical alts to change)
	    ((cat list)
	     (opt ((conjunction ((lex "and")))))
	     (conjunction ((cat conj) (lex given)))
	     (alt list
		  (:demo "How many conjuncts are there: 0, 1, 2, or more?")
		  (((distinct ((car none)))) ;; the list is empty
		   ((distinct ((cdr ((car none))))) ;; the list has only 1 elt
		    (constituent ((cat {^ ^ common part-of-speech})
				  (alt 
				   (((cat clause)
				     (mood {^ ^ common mood})
				     (finite {^ ^ common finite})
				     (non-finite {^ ^ common non-finite})
				     (interrogative {^ ^ common interrogative})
				     (relative-type {^ ^ common relative-type})
				     (scope {^ ^ common scope}))
				    ((cat np)
				     (case {^ ^ common case}))))))
		    (constituent {^ distinct car})
		    (pattern (constituent)))
		   ((distinct ((cdr ((cdr ((car none))))))) ;; list has only 2 elts
		    (constituent1 ((cat {^ ^ common part-of-speech})
				   (punctuation ((after none)))
				   (alt 
				    (((cat clause)
				      (mood {^ ^ common mood})
				      (finite {^ ^ common finite})
				      (non-finite {^ ^ common non-finite})
				      (interrogative {^ ^ common interrogative})
				      (relative-type {^ ^ common relative-type})
				      (scope {^ ^ common scope}))
				     ((cat np)
				      (case {^ ^ common case}))))))
		    ;; Do ellipsis of verb?
		    (opt ((constituent1 
			   ((verb ((lex {^  ^ ^ ^ constituent2 verb lex})
				   (voice {^ ^ ^ ^ constituent2 verb voice})))))
			  (constituent2 ((verb ((gap yes)))))))
		    ;; Could look at ellipsis of subject - but that's tricky
		    ;; all we have in the input is agent/medium etc.
		    ;; Want to test on subject not agent.
		    (constituent2 ((cat {^ ^ common part-of-speech})
				   (alt 
				    (((cat clause)
				      (mood {^ ^ common mood})
				      (finite {^ ^ common finite})
				      (non-finite {^ ^ common non-finite})
				      (interrogative {^ ^ common interrogative})
				      (relative-type {^ ^ common relative-type})
				      (scope {^ ^ common scope}))
				     ((cat np)
				      (case {^ ^ common case}))))))
		    (constituent1 {^ distinct car})
		    (constituent2 {^ distinct cdr car})
		    (pattern (constituent1 conjunction constituent2)))
		   ((distinct ((cdr ((cdr ((car given))))))) ;; list w/more than 3 elts
		    (constituent ((cat {^ ^ common part-of-speech})
				  (alt 
				   (((cat clause)
				     (mood {^ ^ common mood})
				     (finite {^ ^ common finite})
				     (non-finite {^ ^ common non-finite})
				     (interrogative {^ ^ common interrogative})
				     (relative-type {^ ^ common relative-type})
				     (scope {^ ^ common scope}))
				    ((cat np)
				     (case {^ ^ common case}))))
				  (punctuation ((after ",")))))
		    (constituent {^ distinct car})
		    (rest ((cat list)
			   (common {^ ^ common})
			   (conjunction {^ ^ conjunction})
			   (distinct {^ ^ distinct cdr})))
		    (pattern (constituent rest))))))

	    ;; ==============================================================
	    ;; 05 CAT PRONOUNS ----------------------------------------------
	    ;; ==============================================================
	    ;; Pronouns have features: pronoun-type, case, animate,
	    ;; person, distance, person, number.
	    ;; Most of the work for personal, question, demonstrative
	    ;; done in morphology routines. Quantified to be treated here.
	    ((cat pronoun))

	    ;; ==============================================================
	    ;; 06 CAT PP : for prepositional phrases ------------------------
	    ;; ==============================================================
	    ((cat pp)
	     (pattern (prep np))
	     (prep ((cat prep) (lex given)))
	     (np ((cat np))))

	    ;;==============================================================
	    ;; 07 CAT DET : for articles -----------------------------------
	    ;;==============================================================
	    ;; No treatment of quantification, pre-det, ord. and cardinal.
	    ((cat det)
	     (number {^ ^ number})

	     (alt demonstrative 
		  (:demo "Is this a demonstrative determiner?")
		  (((demonstrative no)
		    (distance none))
		   ((alt (((demonstrative given))
			  ((distance given))))
		    (demonstrative yes)
		    (definite yes)
		    (alt distance 
			 (:index distance)
			 (:demo "Is this a reference to a near or to a far object?")
			 (((distance near)
			   (alt (:index number)
				(((number plural) 
				  (lex "these"))
				 ((number singular)
				  (lex "this")))))
			  ((distance far)
			   (alt (:index number)
				(((number plural)
				  (lex "those"))
				 ((number singular)
				  (lex "that"))))))))))
     
	     (alt possessive 
		  (:demo "Is this a possessive determiner?")
		  (((possessive no))
		   ((possessive given)
		    (possessive yes)
		    (definite yes)
		    (alt 
		     (((np-type pronoun)
		       (pronoun-type personal)
		       (alt (:index person)
			    (((person first)
			      (alt (:index number)
				   (((number singular) (lex "my"))
				    ((number plural) (lex "our")))))
			     ((person second) (lex "your"))
			     ((person third) 
			      (alt (:index number) 
				   (((number singular)
				     (alt (:index gender)
					  (((gender masculine) (lex "his"))
					   ((gender feminine) (lex "her"))
					   ((gender neuter) (lex "its")))))
				    ((number plural) (lex "their"))))))))
		      ((pattern (possessive-det))
		       (possessive-det ((cat np)
					(np-type {^ ^ np-type})
					(number {^ ^ number})
					(definite {^ ^ definite})
					(head {^ ^ head})
					(lex {^ ^ lex})
					(case possessive)))
		       (alt (:index np-type)
			    (((np-type common)
			      (possessive-det ((determiner {^ ^ determiner})
					       (qualifier {^ ^ qualifier})
					       (describer {^ ^ describer}))))
			     ((np-type proper))
			     ((np-type pronoun)
			      (alt (:index pronoun-type)
				   (((pronoun-type question))
				    ((pronoun-type relative))
				    ((pronoun-type quantified)))))))))))))
	     (alt determiner 
		  (:demo "Is the determiner definite? countable?")
		  (((demonstrative given) (demonstrative yes))
		   ((possessive given) (possessive yes))
		   ((countable no) (gap yes))
		   ((demonstrative no)
		    (possessive no)
		    (countable yes)
		    (definite yes)
		    (lex "the"))
		   ((definite no)
		    (countable yes)
		    (opt ((number singular)
			  (lex "a")))))))
	   
	    ((cat adj))
	    ((cat conj))
	    ((cat relpro))
	    ((cat prep))
	    ((cat adv))
	    ((cat verb))
	    ((cat modal))
	    ((cat pronoun))
	    ((cat noun))

	    ))))

  (format t "~%gr4 installed.~%")
  (values))


