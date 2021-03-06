(define shen 
  -> (do (credits) (loop)))

(define loop
   -> (do (initialise_environment)
          (prompt) 
          (trap-error (read-evaluate-print) (/. E (pr (error-to-string E) (value *stinput*)))) 
          (loop)))

\The current version.\

(define version
  S -> (set *version* S))

(version "version 4.0")

\Prints credits.\
(define credits
 -> (do (output "~%Shen 2010, copyright (C) 2010 Mark Tarver~%")
        (output "www.shenlanguage.org, ~A~%" (value *version*)) 
        (output "running under ~A, implementation: ~A" (value *language*) (value *implementation*))
        (output "~%port ~A ported by ~A~%" (value *port*) (value *porters*))))

\Initialise environment - set calls to 0 for trace package; set logical inferences to 0 \
(define initialise_environment 
  -> (multiple-set [*call* 0 *infs* 0 *dumped* [] *process-counter* 0 *catch* 0]))  

(define multiple-set
  [] -> []
  [S V | M] -> (do (set S V) (multiple-set M)))
                 
(define destroy
  F -> (declare F []))

(set *history* [])

(define read-evaluate-print 
  -> (let Lineread (toplineread)  
          History (value *history*)
          NewLineread (retrieve-from-history-if-needed Lineread History)
          NewHistory (update_history NewLineread History)
          Parsed (fst NewLineread)         
          (toplevel Parsed)))

(define retrieve-from-history-if-needed
   (@p _ [C1 C2]) [H | _] -> (let PastPrint (prbytes (snd H))
                                    H)  where (and (= C1 (exclamation)) (= C2 (exclamation)))
   (@p _ [C | Key]) H -> (let Key? (make-key Key H)
                                Find (head (find-past-inputs Key? H)) 
                                PastPrint (prbytes (snd Find))
                                Find)   where (= C (exclamation))
   (@p _ [C]) H -> (do (print-past-inputs (/. X true) (reverse H) 0)
                         (abort))       where (= C (percent))
   (@p _ [C | Key]) H -> (let Key? (make-key Key H)
                                Pastprint (print-past-inputs Key? (reverse H) 0)
                                (abort))  where (= C (percent))
   Lineread _ -> Lineread)

(define percent
  -> 37)

(define exclamation
  ->  33) 

(define prbytes
  Bytes -> (do (map (/. Byte (pr (n->string Byte))) Bytes) 
               (nl)))

(define update_history 
  Lineread History -> (set *history* [Lineread  | History]))   

(define toplineread
  -> (toplineread_loop (read-byte) []))

(define toplineread_loop
  Byte _ -> (error "line read aborted")  where (= Byte (hat))
  Byte Bytes -> (let Line (compile (function <st_input>) Bytes)
                    (if (or (= Line fail!) (empty? Line))
                        (toplineread_loop (read-byte) (append Bytes [Byte]))
                        (@p Line Bytes)))
                            	where (element? Byte [(newline) (carriage-return)])
  Byte Bytes -> (toplineread_loop (read-byte) (append Bytes [Byte])))

(define hat
  -> 94)

(define newline
   -> 10)
     
(define carriage-return
    -> 13)    
  
(define tc
  + -> (set *tc* true)
  - -> (set *tc* false)
  _ -> (error "tc expects a + or -"))

(define prompt
  -> (if (value *tc*)
         (output  "~%~%(~A+) " (length (value *history*)))
         (output  "~%~%(~A-) " (length (value *history*)))))

(define toplevel
  Parsed -> (toplevel_evaluate Parsed (value *tc*)))

(define find-past-inputs
  Key? H -> (let F (find Key? H) 
              (if (empty? F) 
                  (error "input not found~%")
                  F)))

(define make-key
  Key H -> (let Atom (hd (compile (function <st_input>) Key))
              (if (integer? Atom)
                  (/. X (= X (nth (+ Atom 1) (reverse H))))
                  (/. X (prefix? Key (trim-gubbins (snd X)))))))

(define trim-gubbins
  [C | X] -> (trim-gubbins X)  where (= C (space))
  [C | X] -> (trim-gubbins X)  where (= C (newline))
  [C | X] -> (trim-gubbins X)  where (= C (carriage-return))
  [C | X] -> (trim-gubbins X)  where (= C (tab))
  [C | X] -> (trim-gubbins X)  where (= C (left-round))
  X -> X)
  
(define space
   -> 32)  
 
(define tab
   -> 9)

(define left-round
  -> 40)

(define find
  _ [] -> []
  F [X | Y] -> [X | (find F Y)]	where (F X)
  F [_ | Y] -> (find F Y))

(define prefix?
  [] _ -> true
  [X | Y] [X | Z] -> (prefix? Y Z)
  _ _ -> false)

(define print-past-inputs
  _ [] _ -> _
  Key? [H | Hs] N -> (print-past-inputs Key? Hs (+ N 1)) 	where (not (Key? H))
  Key? [(@p _ Cs) | Hs] N -> (do (output "~A. " N) 
                                 (do (prbytes Cs) 
                                     (print-past-inputs Key? Hs (+ N 1)))))
                                 
(define toplevel_evaluate
  [X : A] true -> (typecheck-and-evaluate X A)  
  [X Y | Z] Boolean -> (do (toplevel_evaluate [X] Boolean)
                            (if (= (value *hush*) hushed) skip (nl))
                            (toplevel_evaluate [Y | Z] Boolean))
  [X] true -> (typecheck-and-evaluate X (gensym A))
  [X] false -> (let Eval (eval-without-macros X)
                   (if (or (= (value *hush*) hushed) (= Eval unhushed))
                       skip
                       (print Eval))))

(define typecheck-and-evaluate
  X A -> (let Typecheck (typecheck X A)
              (if (= Typecheck false)
                  (error "type error~%")
                  (let Eval (eval-without-macros X)
                       Type (pretty-type Typecheck)
                       (if (or (= (value *hush*) hushed) (= X unhushed))
                           skip
                           (output "~S : ~R" Eval Type))))))

(define pretty-type
  Type -> (mult_subst (value *alphabet*) (extract-pvars Type) Type))

(define extract-pvars
  X -> [X]  where (pvar? X)
  [X | Y] -> (union (extract-pvars X) (extract-pvars Y))
  _ -> [])

(define mult_subst
  [] _ X -> X
  _ [] X -> X
  [X | Y] [W | Z] A -> (mult_subst Y Z (subst X W A)))