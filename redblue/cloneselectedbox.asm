; Routine: CloneWRAMBoxtoSRAMBox2
;
; Purpose: Clones Pokémon in the currently selected box to Box 2. Box 2 is
;          overwritten in this process.
; 
; Method:  Clones the box currently loaded in WRAM ($DA80) into Box 2 of
;          the SRAM ($A462) and then updates all necessary checksums to
;          ensure the save file remains valid.
; ===================================================================================

CloneWRAMBoxtoSRAMBox2::
	; Enables write-access to the cartridge's save memory (SRAM) and
	; configures the memory bank controller (MBC1) to make SRAM Bank 2
	; (containing Boxes 1-6) the active bank.
	ld   a, $0A
	ld   [$0000], a
	ld   a, $1
	ld   [$6000], a
	ld   a, $2
	ld   [$4000], a

	; Sets up the arguments for the CopyData routine and calls it. This
	; copies the entire 1122-byte box data from the WRAM buffer to the
	; destination (Box 2) in SRAM.
	ld   hl, $DA80
	ld   de, $A462
	ld   bc, $0462
	call $00B5

	; Recalculates the main checksum for the entire SRAM bank. This is done
	; with a manual bankswitch because the SAVCheckSum routine requires its
	; arguments in HL and BC, creating a conflict with the Bankswitch
	; routine. The resulting checksum is safely preserved.
	ld   hl, $A000
	ld   bc, $1A4C
	ld   a, [$FF50]
	push af
	ld   a, $1C
	ld   [$2000], a
	call $7856
	push af
	pop  hl
	pop  af
	ld   [$2000], a
	ld   a, l
	ld   [$BA4C], a

	; Recalculates the individual checksum for all 6 boxes in the bank.
	; This uses the game's built-in Bankswitch routine ($35D6),
	; which is safe and efficient here as the target routine
	; CalcIndividualBoxCheckSums takes no arguments.
	ld   b, $1C
	ld   hl, $7863
	call $35D6

	; Disables write-access to SRAM and reverts the MBC1 controller back
	; to its default ROM banking mode.
	xor  a
	ld   [$6000], a
	ld   [$0000], a
	ret