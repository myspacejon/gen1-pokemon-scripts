; ===================================================================================
; Routine: CloneWRAMBoxtoSRAMBox2
;
; Purpose: Clones Pokémon in the currently selected box to Box 2. Box 2 is
;          overwritten in this process.
; 
; Notes:   We intentionally omit checksum calculations and the write to
;          set banking mode, as they are not validated or required by the
;          game. See commit e4b5eaac0f03b43a513d3cdfd20f85d46ce97cb0 for reference.
;
; ===================================================================================

CloneWRAMBoxtoSRAMBox2::

	; Enables write-access to the cartridge's save memory (SRAM) and selects
	; SRAM Bank 2 (containing Boxes 1-6) as the active bank.
	ld   a, $0A
	ld   [$0000], a
	ld   a, $2
	ld   [$4000], a
	
	; Sets up the arguments for the CopyData routine and calls it. This
	; copies the entire 1122-byte box data from the WRAM buffer to the
	; destination (Box 2) in SRAM.
	ld   hl, $DA80
	ld   de, $A462
	ld   bc, $0462
	call $00B5

	; Disables write-access to SRAM to protect the save data before
	; returning from the subroutine.
	xor  a
	ld   [$0000], a
	ret