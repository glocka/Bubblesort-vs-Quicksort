;-------------------------------------------------------------------------------
; Quicksort program for use with STOY
; Reads values from STDIN, when 0 is read the sorting starts
; Can currently sort up to 26 values excluding the ending 0
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; main function
;-------------------------------------------------------------------------------

MAIN    LDA RF 0xFD     ;stack pointer
        ;LDA R0 0
        LDA R1 1
        LDA RA ARRAY    ;array
        
                        ;prolog
        ADD RE RF R0
        PUSH RE         ;save old base pointer on stack
                        ;set base pointer of MAIN
        LDA R7 2
        SUB RF RF R7    ;make room for 2 local variables
                        ;end of prolog

        LDA R2 0        ;array pointer
        LDA R3 0        ;input print counter
        LDA R4 0        ;main counter
        LDA R5 0        ;print compare var
        LDA R7 0        ;0 for l parameter for first call of QUICKS

        ;get numbers from stdin until 0 is read
M0      ADD R2 RA R4
        LD R3 0xFE
        BZ R3 M0
        LD R3 0xFF
        ST R0 0xFE
        BZ R3 SRT
        STI R3 R2
        ADD R4 R4 R1
        BZ R0 M0

        ;sort array
SRT     SUB R4 R4 R1
        ;STI R7 0 RF
	;STI R4 1 RF ;warum hier 1und nicht 0
        PUSH R4
        PUSH R7

        CALL QUICKS     ;quickSort(array, 0, counter)
        ADD RF RF R1
        POP R4

        LDA R3 0	;pr_counter = 0
        BZ R0 PR0

        ;print number to stdout
PR0     SUB R5 R4 R3	;comp = counter - pr_counter
        BP R5 PR1       ;if(comp > 0) goto PR1
        BZ R5 PR1 	;if(comp = 0) goto PR1
        BZ R0 EPI       ;goto EPI

PR1     ADD R2 RA R3
        LDI RD R2	;arr_pointer = array + pr_counter
        BZ RD PR3       ;if(*arr_pointer == 0) goto PR3
        BZ R0 PR2       ;goto PR2

PR2     ST RD 0xFF      ;printf("%x\n", *arr_pointer)
        BZ R0 PR3       ;goto PR3

PR3     ADD R3 R3 R1	;pr_counter = pr_counter + 1
        BZ R0 PR0       ;goto PR0

EPI     LDA R7 2
        ADD RF RF R7    ;epilog: restore old stackpointer
        POP RE          ;restore old base pointer
        HLT

;-------------------------------------------------------------------------------
; quicksort function
;-------------------------------------------------------------------------------

QUICKS  PUSH RE         ;prolog: save base pointer of caller
        ADD RE RF R0    ;set base pointer of QUICKS
        LDA R7 3
        SUB RF RF R7    ;set stack pointer to have room for 3 local variables
                        ;end of prolog
        LDA R3 2
        ADD R2 RE R3
        LDI RB R2 
        
        ADD R2 R2 R1
        LDI RC R2     ;RC = r

        ;R2 temp
        ;R3 temp2
        ;R4 pivot
        ;R5 j
        ;R6 i
        ;R7 swap
        ;RD swap2        
        ;R8 array pointer 1
        ;R9 array pointer 2

        SUB R2 RC RB
        STI R2 0 RF
        BP R2 QS
        BZ R0 QEPI

QS      ADD R4 RB R0    ;pivot = l
        ADD R5 RC R0    ;j = r
        ADD R6 RB R0    ;i = l

Q0      SUB R2 R5 R6	;temp = j - i
        BP R2 Q1        ;if(temp > 0) goto Q1
        BZ R0 SWP       ;goto SWP

Q1      ADD R8 RA R4	;arr_pointer1 = array + pivot
        ADD R9 RA R6	;arr_pointer2 = array + i
        LDI R7 R8	;swap = *arr_pointer1
        LDI RD R9	;swap2 = *arr_pointer2
        SUB R2 R7 RD 	;temp = swap - swap2
        SUB R3 RC R6 	;temp2 = r - i
        BP R2 Q7        ;if(temp > 0) goto Q7
        BZ R2 Q7        ;if(temp == 0) goto Q7
        BZ R0 Q3        ;goto Q3

Q7      BP R3 Q2        ;if(temp2 > 0) goto Q2
        BZ R0 Q3        ;goto Q3

Q2      ADD R6 R6 R1	;i = i + 1
        BZ R0 Q1        ;goto Q1

Q3      ADD R8 RA R5	;arr_pointer1 = array + j
        ADD R9 RA R4    ;arr_pointer2 = array + pivot
        LDI R7 R8	;swap = *arr_pointer1
        LDI RD R9	;swap2 = *arr_pointer2
        SUB R2 R7 RD 	;temp = swap - swap2
        BP R2 Q4        ;if(temp > 0) goto Q4
        BZ R0 Q5        ;goto Q5

Q4      SUB R5 R5 R1	;j = j - 1
        BZ R0 Q3        ;goto Q3

Q5      SUB R2 R5 R6 	;temp = j - i
        BP R2 Q6        ;if(temp > 0) goto Q6
        BZ R0 Q0        ;goto Q0

Q6      ADD R8 RA R6	;arr_pointer1 = array + i
        ADD R9 RA R5	;arr_pointer = array + j
 	LDI R7 R8       ;swap = *arr_pointer1
        LDI RD R9       ;swap2 = *arr_pointer2
        STI RD R8       ;*arr_pointer1 = swap2
        STI R7 R9       ;*arr_pointer2 = swap
        BZ R0 Q0        ;goto Q0

SWP     ADD R8 RA R4	;arr_pointer1 = array + pivot
        ADD R9 RA R5	;arr_pointer2 = array + j
        LDI R7 R8       ;swap = *arr_pointer1
        LDI RD R9       ;swap2 = *arr_pointer2
        STI RD R8       ;*arr_pointer1 = swap2
        STI R7 R9       ;*arr_pointer2 = swap

        ADD RD RC R0    ;swap2 = old_r
        SUB RC R5 R1    ;new_r = j - 1
        PUSH RD
        PUSH RC
        PUSH RB

        CALL QUICKS     ;quickSort(a, l, new_r)
        POP RB
        POP RC
        POP RD

        ADD RC RD R0    ;RC = old_r
        ADD RB R5 R1    ;new_l = j + 1

        PUSH RC
        PUSH RB

        CALL QUICKS     ;quickSort(a, new_l, r)
        ADD RF RF R1
        ADD RF RF R1

        BZ R0 QEPI

QEPI    LDA R7 3
        ADD RF RF R7    ;epilog: restore previous stack pointer
        POP RE          ;restore base pointer of caller
        RET

ARRAY   DUP 50          ;array[50]
