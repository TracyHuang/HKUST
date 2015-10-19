#Name: GAN, Bo
#ID: 20025680
#Email: bgan@stu.ust.hk
#Lab Section: LA5
#Bonus -- left-movement key: j    right-movement key: l


#=====================#
# THE SUBMARINES GAME #
#=====================#

#---------- DATA SEGMENT ----------
	.data

ship:	.word 320 90 1 4	# 4 words for 4 properties of the ship: (in this order) top-left corner's x-coordinate, top-left corner's y-coordinate, image index, speed  
shipSize: .word 160 60		# ship image's width and height

submarines:	.word -1:500	# 5 words for each submarine: (in this order) top-left corner's x-coordinate, top-left corner's y-coordinate, image index, speed, Hit point  
submarineSize: .word 80 40	# submarine image's width and height

dolphins:	.word -1:500	# 5 words for each dolphin: (in this order) top-left corner's x-coordinate, top-left corner's y-coordinate, image index, speed, Hit point  
dolphinSize: .word 60 40	# dolphin image's width and height

bombs:	.word -1:30	# 5 words for each bomb: (in this order) top-left corner's x-coordinate, top-left corner's y-coordinate, image index, speed, status  
bombSize: .word 30 30	# bomb image's width and height


msg0:	.asciiz "Enter the number of dolphins (max. limit of 5) you want? "
msg1:	.asciiz "Invalid size!\n"
msg2:	.asciiz "Enter the seed for random number generator? "
msg3:	.asciiz "You have won!"
newline: .asciiz "\n"

title: .asciiz "The Submarines game"
# game image array constructed from a string of semicolon-delimited image files
# array index		0		1	2	3	4		5		6		7		8	9		10			11		12		13
images: .asciiz "background.png;shipR.png;shipL.png;subR.png;subL.png;subDamagedR.png;subDamagedL.png;subDestroyed.png;dolphinR.png;dolphinL.png;dolphinDestroyed.png;simpleBomb.png;remoteBombD.png;remoteBombA.png"


# The following registers are used throughout the program for the specified purposes,
# so using any of them for another purpose must preserve the value of that register first: 
# s0 -- total number of dolphins in a game level
# s1 -- total number of submarines in a game level
# s2 -- current game score
# s3 -- current game level
# s4 -- current number of available simple bombs in a game level
# s5 -- current number of available remote bombs in a game level
# s6 -- starting time of a game iteration


#---------- TEXT SEGMENT ----------
	.text
	


main:
#-------(Start main)------------------------------------------------

	jal setting				# the game setting
	nop
	ori $s3, $zero, 1			# level = 1
	ori $s2, $zero, 0			# score = 0

	
	jal createGame				# create the game 
	nop
	#----- initialize game objects and information, and create game screen ---
	jal createGameObjects
	nop
	jal setGameStateOutput
	nop
	jal initgame				# initalize the first game level
	nop
	jal updateGameObjects
	nop
	jal createGameScreen
	nop
	#-------------------------------------------------------------------------
	
main1:
	jal getCurrentTime			# Step 1 of the game loop 
	nop
	ori $s6, $v0, 0    			# v1 keeps the iteration starting time

	jal removeDestroyedObjects		# Step 2 of the game loop
	nop
	jal processInput			# Step 3 of the game loop
	nop
	jal checkBombHits			# Step 4 of the game loop
	nop
	jal updateDamagedImages			# Step 5 of the game loop
	nop

	jal isLevelUp				# Step 6 of the game loop
	nop
	bne $v0, $zero, main2			# the current level is won
	nop

	jal moveShipSubmarinesDolphins		# Step 7 of the game loop
	nop	
	jal moveBombs				# Step 8 of the game loop
	nop

updateScreen:
	jal updateGameObjects			# Step 9 of the game loop
	nop
	jal redrawScreen
	nop

	ori $a0, $s6, 0				# Step 10 of the game loop
	li $a1, 30
	jal pauseExecution
	nop
	j main1
	nop
	
main2:	
	li $t0, 10				# the last level is 10
	beq $s3, $t0, main3 			# the last level and hence the whole game is won
	nop
	addi $s3, $s3, 1			# increment level
	li $t0, 5
	div $s3, $t0
	mfhi $t0
	beq $t0, $zero, double_dolphin_num	# level no. is divisible by 5
	nop
	addi $s0, $s0, 3			# dolphin_num = dolphin_num + 3
	j main_continue
	nop
double_dolphin_num:
	sll $s0, $s0, 1				# dolphin_num = dolphin_num * 2
main_continue:
	addi $s1, $s0, 3			# submarine_num = dolphin_num + 3

	#----- re-initialize game objects and information for next level --------
	jal createGameObjects
	nop
	jal setGameStateOutput
	nop

	jal initgame				# initialize the next game level
	nop
	#-------------------------------------------------------------------------

	j updateScreen
	nop

main3: 
	jal setGameoverOutput			# GAME OVER!
	nop
	jal redrawScreen   
	nop
	j end_main
	nop

#-------(End main)--------------------------------------------------
end_main:

# Terminate the program
#----------------------------------------------------------------------
ori $v0, $zero, 10
syscall

# Function: Setting up the game
setting:
#===================================================================

	addi $sp, $sp, -4
	sw $ra, 0($sp)

setting1:
	ori $t0, $zero, 5			# Max number of dolphins
	
	la $a0, msg0				# Enter the number of dolphins you want?
	ori $v0, $zero, 4
	syscall
	
	ori $v0, $zero, 5			# cin >> dolphin_num
	syscall
	or $s0, $v0, $zero

	slt $t4, $t0, $s0
	bne $t4, $zero, setting3
	nop
	slti $t4, $s0, 1
	bne $t4, $zero, setting3
	nop
	addi $s1, $s0, 3			# submarine_num = dolphin_num + 3
	j setting2
	nop

setting3:
	la $a0, msg1
	ori $v0, $zero, 4			# Invalid size
	syscall
	j setting1
	nop
	
setting2:
	la $a0, newline
	ori $v0, $zero, 4
	syscall

	la $a0, msg2				# Enter the seed for random number generator?
	ori $v0, $zero, 4
	syscall
	
	ori $v0, $zero, 5			# cin >> seed
	syscall

	ori $a0, $v0, 0				# set the seed of the random number generator
	jal setRandomSeed
	nop

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	nop

#---------------------------------------------------------------------------------------------------------------------
# Function: initalize to a new level
# Generate random location and speed for submarines and dolphins
# Set the image index of submarines and dolphins according to their own moving direction
# Set the Hit point of the submarines and dolphins
# Set the available number of the bombs
# Initialize the image index and speed of the bombs

initgame: 			
#===================================================================

############################
# Please add your code here#
############################

CreaTempXYArr:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	addu $t9, $s0, $s1
	sll $t0, $t9, 3
	subu $sp, $sp, $t0
	
DolpRawXYGen:
	la $t2, dolphinSize
	lw $t0, 0($t2)
	lw $t1, 4($t2)
	subu $t0, $zero, $t0
	subu $t1, $zero, $t1
	addiu $t0, $t0, 800
	addiu $t1, $t1, 250
	xor $t2, $t2, $t2
	or $t7, $zero, $sp
	DolpRawXYGenLoop:
		beq $t2, $s0, DolpRawXYGenDone
		nop
	DolpRawXYGenOnce:
		or $a0, $zero, $t0
		jal randnum
		nop
		or $t3, $zero, $v0
		or $a0, $zero, $t1
		jal randnum
		nop
		or $t4, $zero, $v0
		xor $t5, $t5, $t5
		or $t6, $zero, $sp
		DolpRawXYCompIfDup:
			beq $t5, $t2, DolpRawXYCompDone
			nop
			lw $t8, 0($t6)
			beq $t8, $t3, DolpRawXYGenOnce
			nop
			lw $t8, 4($t6)
			beq $t8, $t4, DolpRawXYGenOnce
			nop
			addiu $t5, $t5, 1
			addiu $t6, $t6, 8
			beq $zero, $zero, DolpRawXYCompIfDup
			nop
	DolpRawXYCompDone:
		sw $t3, 0($t7)
		sw $t4, 4($t7)
		addiu $t2, $t2, 1
		addiu $t7, $t7, 8
		beq $zero, $zero, DolpRawXYGenLoop
		nop
DolpRawXYGenDone:

SubmarRawXYGen:
	la $t2, submarineSize
	lw $t0, 0($t2)
	lw $t1, 4($t2)
	subu $t0, $zero, $t0
	subu $t1, $zero, $t1
	addiu $t0, $t0, 800
	addiu $t1, $t1, 250
	addu $t2, $zero, $s0
	sll $t7, $s0, 3
	addu $t7, $t7, $sp
	SubmarRawXYGenLoop:
		beq $t2, $t9, SubmarRawXYGenDone
		nop
	SubmarRawXYGenOnce:
		or $a0, $zero, $t0
		jal randnum
		nop
		or $t3, $zero, $v0
		or $a0, $zero, $t1
		jal randnum
		nop
		or $t4, $zero, $v0
		xor $t5, $t5, $t5
		or $t6, $zero, $sp
		SubmarRawXYCompIfDup:
			beq $t5, $t2, SubmarRawXYCompDone
			nop
			lw $t8, 0($t6)
			beq $t8, $t3, SubmarRawXYGenOnce
			nop
			lw $t8, 4($t6)
			beq $t8, $t4, SubmarRawXYGenOnce
			nop
			addiu $t5, $t5, 1
			addiu $t6, $t6, 8
			beq $zero, $zero, SubmarRawXYCompIfDup
			nop
	SubmarRawXYCompDone:
		sw $t3, 0($t7)
		sw $t4, 4($t7)
		addiu $t2, $t2, 1
		addiu $t7, $t7, 8
		beq $zero, $zero, SubmarRawXYGenLoop
		nop
SubmarRawXYGenDone:

StoreDolpInitData:
	la $t0, dolphins
	ori $t7, $zero, 5
	ori $t8, $zero, 20
	xor $t1, $t1, $t1
	or $t2, $zero, $sp
	StoreDolpInitDataLoop:
		beq $t1, $s0, StoreDolpInitDataDone
		nop
		lw $t3, 0($t2)
		sw $t3, 0($t0)
		lw $t3, 4($t2)
		addiu $t3, $t3, 250
		sw $t3, 4($t0)
		ori $a0, $zero, 2
		jal randnum
		nop
		addiu $v0, $v0, 8
		sw $v0, 8($t0)
		sw $t7, 12($t0)
		sw $t8, 16($t0)
		addiu $t0, $t0, 20
		addiu $t1, $t1, 1
		addiu $t2, $t2, 8
		beq $zero, $zero, StoreDolpInitDataLoop
		nop
StoreDolpInitDataDone:

StoreSubmarInitData:
	la $t0, submarines
	ori $t7, $zero, 6
	ori $t8, $zero, 10
	or $t1, $zero, $s0
	sll $t2, $s0, 3
	addu $t2, $t2, $sp
	StoreSubmarInitDataLoop:
		beq $t1, $t9, StoreSubmarInitDataDone
		nop
		lw $t3, 0($t2)
		sw $t3, 0($t0)
		lw $t3, 4($t2)
		addiu $t3, $t3, 250
		sw $t3, 4($t0)
		ori $a0, $zero, 2
		jal randnum
		nop
		addiu $v0, $v0, 3
		sw $v0, 8($t0)
		sw $t7, 12($t0)
		sw $t8, 16($t0)
		addiu $t0, $t0, 20
		addiu $t1, $t1, 1
		addiu $t2, $t2, 8
		beq $zero, $zero, StoreSubmarInitDataLoop
		nop
StoreSubmarInitDataDone:

ResetBombs:
	ori $s4, $zero, 5
	ori $s5, $zero ,1
	la $t0, bombs
	addiu $t6, $zero, -1
	ori $t7, $zero, 4
	ori $t1, $zero, 6
	xor $t2, $t2, $t2
	ResetBombsLoop:
		beq $t2, $t1, ResetBombsLoopDone
		nop
		sw $t6, 8($t0)
		sw $t7, 12($t0)
		sw $zero, 16($t0)
		addiu $t2, $t2, 1
		addiu $t0, $t0, 20
		beq $zero, $zero, ResetBombsLoop
		nop
ResetBombsLoopDone:

	sll $t9, $t9, 3
	addu $sp, $sp, $t9
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra
	nop
 



#---------------------------------------------------------------------------------------------------------------------
# Function: remove the destroyed submarines and dolphins from the screen

removeDestroyedObjects:				
#===================================================================

############################
# Please add your code here#
############################
RemoveDestrSubmar:
	xor $t0, $t0, $t0
	la $t1, submarines
	ori $t3, $zero, 7
	addiu $t4, $zero, -1
	RemoveDestrSubmarLoop:
		beq $t0, $s1, DestrSubmarRemoved
		nop
		lw $t2, 8($t1)
		bltz $t2, RemoveNextDestrSubmar
		nop
		bne $t2, $t3, RemoveNextDestrSubmar
		nop
		sw $t4, 8($t1)
	RemoveNextDestrSubmar:
		addiu $t0, $t0, 1
		addiu $t1, $t1, 20
		beq $zero, $zero, RemoveDestrSubmarLoop
		nop
DestrSubmarRemoved:

RemoveDestrDolp:
	xor $t0, $t0, $t0
	la $t1, dolphins
	ori $t3, $zero, 10
	RemoveDestrDolpLoop:
		beq $t0, $s0, DestrDolpRemoved
		nop
		lw $t2, 8($t1)
		bltz $t2, RemoveNextDestrDolp
		nop
		bne $t2, $t3, RemoveNextDestrDolp
		nop
		sw $t4, 8($t1)
	RemoveNextDestrDolp:
		addiu $t0, $t0, 1
		addiu $t1, $t1, 20
		beq $zero, $zero, RemoveDestrDolpLoop
		nop
DestrDolpRemoved:

	jr $ra
	nop





#---------------------------------------------------------------------------------------------------------------------
# Function: check any hits between an Activated bomb and a submarine or dolphin,
# and then handle the hits:
# change the hit submarine or dolphin's Hit point and change the score accordingly
# remove the bomb and add it back to the available ones

checkBombHits:				
#===================================================================

############################
# Please add your code here#
############################

	addiu $sp, $sp, -32
	sw $s6, 28($sp)
	sw $s5, 24($sp)
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	la $t2, bombSize
	lw $t3, 4($t2)
	lw $t2, 0($t2)
	
	la $s0, dolphinSize
	lw $s1, 4($s0)
	lw $s0, 0($s0)
	
	
	la $s3, submarineSize
	lw $s5, 0($s3)
	lw $s6, 4($s3)
	srl $s4, $s5, 1
	srl $s3, $s5, 4
	subu $s3, $s4, $s3
	srl $s4, $s4, 2
CheckBombHit:
	ori $t4, $zero, 6
	xor $t5, $t5, $t5
	la $t9, bombs
	CheckBombHitLoop:
		beq $t5, $t4, CheckBombHitDone
		nop
		lw $t8, 8($t9)
		bltz $t8, CheckNextBomb
		nop
		lw $t8, 16($t9)
		beq $t8, $zero, CheckNextBomb
		nop
		xor $s2, $s2, $s2
		lw $t0, 0($t9)
		lw $t1, 4($t9)
	CheckBombHitSub:
		lw $t6, 8($sp)
		sll $t6, $t6, 2
		sll $t7, $t6, 2
		addu $t7, $t7, $t6
		la $t6, submarines
		addu $t7, $t7, $t6
		or $a3, $zero, $s6
		CheckBombHitSubLoop:
			or $a2, $zero, $s5
			beq $t6, $t7, CheckBombHitSubDone
			nop
			lw $t8, 8($t6)
			bltz $t8, CheckBombHitNextSub
			nop
			lw $a0, 0($t6)
			lw $a1, 4($t6)
			jal isIntersected
			beq $v0, $zero, CheckBombHitNextSub
			nop
			lw $t8, 16($t6)
			beq $t8, $zero, CheckBombHitNextSub
			nop
			addu $a0, $a0, $s3
			or $a2, $zero, $s4
			jal isIntersected
			beq $v0, $zero, BombHitSubSide
			nop
		BombHitSubMid:
			beq $zero, $zero, DeductAllSubmarHitPoint
			nop
		BombHitSubSide:
			lw $t8, 16($t6)
			addiu $t8, $t8, -5
			bgez $t8, DeductFivePointFromSubmar
			nop
		DeductAllSubmarHitPoint:
			lw $t8, 16($t6)
			lw $s2, 12($sp)
			addu $t8, $t8, $s2
			sw $t8, 12($sp)
			sw $zero, 16($t6)
			beq $zero, $zero, BombHitSubDone
			nop
		DeductFivePointFromSubmar:
			sw $t8, 16($t6)
			lw $t8, 12($sp)
			addiu $t8, $t8, 5
			sw $t8, 12($sp)
		BombHitSubDone:
			nor $s2, $zero, $zero
		CheckBombHitNextSub:
			addiu $t6, $t6, 20
			beq $zero, $zero, CheckBombHitSubLoop
			nop
	CheckBombHitSubDone:
	CheckBombHitDolp:
		lw $t6, 4($sp)
		sll $t6, $t6, 2
		sll $t7, $t6, 2
		addu $t7, $t7, $t6
		la $t6, dolphins
		addu $t7, $t7, $t6
		or $a2, $zero, $s0
		or $a3, $zero, $s1
		CheckBombHitDolpLoop:
			beq $t6, $t7, CheckBombHitDolpDone
			nop
			lw $t8, 8($t6)
			bltz $t8, CheckBombHitNextDolp
			nop
			lw $a0, 0($t6)
			lw $a1, 4($t6)
			jal isIntersected
			beq $v0, $zero, CheckBombHitNextDolp
			nop
			lw $t8, 16($t6)
			beq $t8, $zero, CheckBombHitNextDolp
			nop
			lw $t8, 16($t6)
			lw $s2, 12($sp)
			subu $t8, $s2, $t8
			sw $t8, 12($sp)
			sw $zero, 16($t6)
			nor $s2, $zero, $zero
		CheckBombHitNextDolp:
			addiu $t6, $t6, 20
			beq $zero, $zero, CheckBombHitDolpLoop
			nop
	CheckBombHitDolpDone:
		beq $s2, $zero, BombHitNothing
		nop
		lw $s2, 8($t9)
		ori $t8, $zero, 13
		beq $t8, $s2, RemoteBombHit
		nop
	SimpleBombHit:
		lw $t8, 20($sp)
		addiu $t8, $t8, 1
		sw $t8, 20($sp)
		beq $zero, $zero, BombHit
		nop
	RemoteBombHit:
		lw $t8, 24($sp)
		addiu $t8, $t8, 1
		sw $t8, 24($sp)
	BombHit:
		addiu $t8, $zero, -1
		sw $t8, 8($t9)
	BombHitNothing:
	CheckNextBomb:
		addiu $t9, $t9, 20
		addiu $t5, $t5, 1
		beq $zero, $zero, CheckBombHitLoop
		nop
CheckBombHitDone:	
	
	lw $s6, 28($sp)
	lw $s5, 24($sp)
	lw $s4, 20($sp)
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 32
	jr $ra
	nop
	



	
#----------------------------------------------------------------------------------------------------------------------
# Function: read and handle the user's input

processInput:
#===================================================================

############################
# Please add your code here#
############################

GetInputStatus:
	lui $t0, 0xffff
	lw $t1, 0($t0)
	beq $t1, $zero, NoInput
	nop
	lw $t1, 4($t0)
	ori $t2, $zero, 113
	beq $t1, $t2, Pressed_q
	nop
	ori $t2, $zero, 49
	beq $t1, $t2, Pressed_1
	nop
	ori $t2, $zero, 50
	beq $t1, $t2, Pressed_2
	nop
	ori $t2, $zero, 101
	beq $t1, $t2, Pressed_e
	nop
	ori $t2, $zero, 106
	beq $t1, $t2, Pressed_j
	nop
	ori $t2, $zero, 108
	bne $t1, $t2, PressProcDone
	nop
	
Pressed_l:
	la $t0, shipSize
	lw $t0, 0($t0)
	subu $t0, $zero, $t0
	addiu $t0, $t0, 800
	la $t1, ship
	lw $t2, 0($t1)
	lw $t3, 12($t1)
	addu $t2, $t2, $t3
	ori $t4, $zero, 1
	lw $t5, 8($t1)
	beq $t4, $t5, ShipRightSameDir
	nop
ShipRightDiffDir:
	sw $t4, 8($t1)
	addu $t2, $t2, $t3
ShipRightSameDir:
	slt $t4, $t2, $t0
	bne $t4, $zero, ShipRightNoOverflow
	nop
ShipRightOverflow:
	or $t2, $zero, $t0
ShipRightNoOverflow:
	sw $t2, 0($t1)
	beq $zero, $zero, PressProcDone
	nop
	
Pressed_j:
	la $t1, ship
	lw $t2, 0($t1)
	lw $t3, 12($t1)
	subu $t2, $t2, $t3
	ori $t4, $zero, 2
	lw $t5, 8($t1)
	beq $t4, $t5, ShipLeftSameDir
	nop
ShipLeftDiffDir:
	sw $t4, 8($t1)
	subu $t2, $t2, $t3
ShipLeftSameDir:
	slt $t4, $t2, $t0
	bgez $t2, ShipLeftNoOverflow
	nop
ShipLeftOverflow:
	xor $t2, $t2, $t2
ShipLeftNoOverflow:
	sw $t2, 0($t1)
	beq $zero, $zero, PressProcDone
	nop
	
Pressed_e:
	bne $s5, $zero, NoRemoteBombThrown
	nop
	la $t0, bombs
	ori $t1, $zero, 12
	ori $t2, $zero, 13
	FindRemoteBombThrown:
		lw $t3, 8($t0)
		beq $t3, $t2, RemoteBombFound
		nop
		beq $t3, $t1, RemoteBombFound
		nop
		addiu $t0, $t0, 20
		beq $zero, $zero, FindRemoteBombThrown
		nop
RemoteBombFound:
	ori $t1, $zero, 1
	sw $t1, 16($t0)
	ori $t1, $zero, 13
	sw $t1, 8($t0)
NoRemoteBombThrown:
	beq $zero, $zero, PressProcDone
	nop

Pressed_2:
	beq $s5, $zero, NoRemoteBombAvail
	nop
	addiu $s5, $s5, -1
	la $t0, shipSize
	lw $t1, 4($t0)
	lw $t0, 0($t0)
	srl $t0, $t0, 1
	la $t2, ship
	lw $t3, 4($t2)
	lw $t2, 0($t2)
	addu $t0, $t0, $t2
	addu $t1, $t1, $t3
	la $t2, bombSize
	lw $t2, 0($t2)
	srl $t2, $t2, 1
	subu $t0, $t0, $t2
	la $t2, bombs
	FindAvailRemoteBomb:
		lw $t3, 8($t2)
		bltz $t3, ThrowRemoteBomb
		nop
		addiu $t2, $t2, 20
		beq $zero, $zero, FindAvailRemoteBomb
		nop
ThrowRemoteBomb:
	ori $t3, $zero, 12
	ori $t4, $zero, 4
	sw $t0, 0($t2)
	sw $t1, 4($t2)
	sw $t3, 8($t2)
	sw $t4, 12($t2)
	sw $zero, 16($t2)
NoRemoteBombAvail:
	beq $zero, $zero, PressProcDone
	nop

Pressed_1:
	beq $s4, $zero, NoSimpleBombAvail
	nop
	addiu $s4, $s4, -1
	la $t0, shipSize
	lw $t1, 4($t0)
	lw $t0, 0($t0)
	srl $t0, $t0, 1
	la $t2, ship
	lw $t3, 4($t2)
	lw $t2, 0($t2)
	addu $t0, $t0, $t2
	addu $t1, $t1, $t3
	la $t2, bombSize
	lw $t2, 0($t2)
	srl $t2, $t2, 1
	subu $t0, $t0, $t2
	la $t2, bombs
	FindAvailSimpleBomb:
		lw $t3, 8($t2)
		bltz $t3, ThrowSimpleBomb
		nop
		addiu $t2, $t2, 20
		beq $zero, $zero, FindAvailSimpleBomb
		nop
ThrowSimpleBomb:
	ori $t3, $zero, 11
	ori $t4, $zero, 4
	ori $t5, $zero, 1
	sw $t0, 0($t2)
	sw $t1, 4($t2)
	sw $t3, 8($t2)
	sw $t4, 12($t2)
	sw $t5, 16($t2)
NoSimpleBombAvail:
	beq $zero, $zero, PressProcDone
	nop

Pressed_q:
	jal end_main
	nop

PressProcDone:
NoInput:
	jr $ra
	nop	




#----------------------------------------------------------------------------------------------------------------------
# Function: move the ship, submarines and dolphins

moveShipSubmarinesDolphins:
#===================================================================

############################
# Please add your code here#
############################

MoveSubmar:
	la $t0, submarineSize
	lw $t0, 0($t0)
	sub $t0, $zero, $t0
	addiu $t0, $t0, 800
	la $t1, submarines
	xor $t2, $t2, $t2
	MoveSubmarLoop:
		beq $t2, $s1, MoveSubmarDone
		nop
		lw $t5, 0($t1)
		lw $t6, 12($t1)
		lw $t3, 8($t1)
		addiu $t4, $t3, -3
		beq $t4, $zero, MoveSubmarRight
		nop
		addiu $t4, $t4, -1
		beq $t4, $zero, MoveSubmarLeft
		nop
		addiu $t4, $t4, -1
		beq $t4, $zero, MoveSubmarRight
		nop
		addiu $t4, $t4, -1
		bne $t4, $zero, MoveNextSubmar
		nop
	MoveSubmarLeft:
		subu $t5, $t5, $t6
		bgtz $t5, MoveSubmarNoAdjust
		nop
		xor $t5, $t5, $t5
		addiu $t3, $t3, -1
		sw $t3, 8($t1)
		beq $zero, $zero, MoveSubmarNoAdjust
		nop
	MoveSubmarRight:
		addu $t5, $t5, $t6
		slt $t7, $t5, $t0
		bne $t7, $zero, MoveSubmarNoAdjust
		nop
		or $t5, $zero, $t0
		addiu $t3, $t3, 1
		sw $t3, 8($t1)
	MoveSubmarNoAdjust:
		sw $t5, 0($t1)
	MoveNextSubmar:
		addiu $t1, $t1, 20
		addiu $t2, $t2, 1
		beq $zero, $zero, MoveSubmarLoop
		nop
MoveSubmarDone:

MoveDolp:
	la $t0, dolphinSize
	lw $t0, 0($t0)
	sub $t0, $zero, $t0
	addiu $t0, $t0, 800
	la $t1, dolphins
	xor $t2, $t2, $t2
	MoveDolpLoop:
		beq $t2, $s0, MoveDolpDone
		nop
		lw $t5, 0($t1)
		lw $t6, 12($t1)
		lw $t3, 8($t1)
		addiu $t4, $t3, -8
		beq $t4, $zero, MoveDolpRight
		nop
		addiu $t4, $t4, -1
		bne $t4, $zero, MoveNextDolp
		nop
	MoveDolpLeft:
		subu $t5, $t5, $t6
		bgtz $t5, MoveDolpNoAdjust
		nop
		xor $t5, $t5, $t5
		addiu $t3, $t3, -1
		sw $t3, 8($t1)
		beq $zero, $zero, MoveDolpNoAdjust
		nop
	MoveDolpRight:
		addu $t5, $t5, $t6
		slt $t7, $t5, $t0
		bne $t7, $zero, MoveDolpNoAdjust
		nop
		or $t5, $zero, $t0
		addiu $t3, $t3, 1
		sw $t3, 8($t1)
	MoveDolpNoAdjust:
		sw $t5, 0($t1)
	MoveNextDolp:
		addiu $t1, $t1, 20
		addiu $t2, $t2, 1
		beq $zero, $zero, MoveDolpLoop
		nop
MoveDolpDone:

	jr $ra
	nop	




#----------------------------------------------------------------------------------------------------------------------
# Function: move the bombs, and then remove those under the
# game screen and add them back to the available ones. 

moveBombs:
#===================================================================

############################
# Please add your code here#
############################

	ori $t0, $zero, 6
	xor $t1, $t1, $t1
	la $t2, bombs
MoveBombsLoop:
	beq $t1, $t0, MoveBombsDone
	nop
	lw $t3, 8($t2)
	bltz $t3, MoveNextBomb
	nop
	lw $t4, 12($t2)
	lw $t5, 4($t2)
	addu $t5, $t5, $t4
	addiu $t6, $t5, -600
	bgez $t6, BombOutOfScreen
	nop
	sw $t5, 4($t2)
	beq $zero, $zero, MoveNextBomb
	nop
BombOutOfScreen:
	addiu $t7, $zero, -1
	sw $t7, 8($t2)
	addiu $t3, $t3, -12
	bgez $t3, AddOneRemoteBombAvail
	nop
AddOneSimpleBombAvail:
	addiu $s4, $s4, 1
	beq $zero, $zero, MoveNextBomb
	nop
AddOneRemoteBombAvail:
	addiu $s5, $s5, 1
MoveNextBomb:
	addiu $t1, $t1, 1
	addiu $t2, $t2, 20
	beq $zero, $zero, MoveBombsLoop
	nop
MoveBombsDone:
	jr $ra
	nop


#----------------------------------------------------------------------------------------------------------------------
# Function: update the image index of any damaged or destroyed submarines and dolphins

updateDamagedImages:
#===================================================================

############################
# Please add your code here#
############################

	la $t1, submarines
	xor $t0, $t0, $t0
	ori $t8, $zero, 5
	ori $t7, $zero, 7
	UpdateDamagedSubmarLoop:
		beq $t0, $s1, UpdateDamagedSubmarDone
		nop
		lw $t2, 8($t1)
		bltz $t2, UpdateNextDamagedSubmar
		nop
		lw $t3, 16($t1)
		beq $t3, $t8, SubmarDamaged
		nop
		bne $t3, $zero, UpdateNextDamagedSubmar
		nop
	SubmarDestoryed:
		sw $t7, 8($t1)
		beq $zero, $zero, UpdateNextDamagedSubmar
		nop
	SubmarDamaged:
		addiu $t2, $t2, -5
		bgez $t2, UpdateNextDamagedSubmar
		nop
		addiu $t2, $t2, 7
		sw $t2, 8($t1)
	UpdateNextDamagedSubmar:
		addiu $t0, $t0, 1
		addiu $t1, $t1, 20
		beq $zero, $zero, UpdateDamagedSubmarLoop
		nop
UpdateDamagedSubmarDone:

	la $t1, dolphins
	xor $t0, $t0, $t0
	ori $t7, $zero, 10
	UpdateDamagedDolpLoop:
		beq $t0, $s0, UpdateDamagedDolpDone
		nop
		lw $t2, 8($t1)
		bltz $t2, UpdateNextDamagedDolp
		nop
		lw $t3, 16($t1)
		bgtz $t3, UpdateNextDamagedDolp
		nop
	DolpDestroyed:
		sw $t7, 8($t1)
	UpdateNextDamagedDolp:
		addiu $t0, $t0, 1
		addiu $t1, $t1, 20
		beq $zero, $zero, UpdateDamagedDolpLoop
		nop
UpdateDamagedDolpDone:

	jr $ra
	nop	




	
#----------------------------------------------------------------------------------------------------------------------
# Function: check if a new level is reached (when all the submarines have been removed)	
# return $v0: 0 -- false, 1 -- true

isLevelUp:
#===================================================================

	ori $v0, $zero, 1

	# check if a submarine is still not removed	
	la $t6, submarines
	li $t7, 0
level_submarine_loop:
	lw $t5, 8($t6)
	slti $t5, $t5, 0
	bne $t5, $zero, level_submarine_loop_continue	# skip removed submarines
	nop
	ori $v0, $zero, 0	# submarine has not been removed yet
	jr $ra
	nop

level_submarine_loop_continue:	
	addi $t7, $t7, 1 
	addi $t6, $t6, 20
	bne $t7, $s1, level_submarine_loop
	nop

	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: check whether two rectangles (say A and B) intersect each other
# return $v0: 0 -- false, 1 -- true
# a0 = x-coordinate of the top-left corner of rectangle A
# a1 = y-coordinate of the top-left corner of rectangle A
# a2 = width of rectangle A
# a3 = height of rectangle A
# t0 = x-coordinate of the top-left corner of rectangle B
# t1 = y-coordinate of the top-left corner of rectangle B
# t2 = width of rectangle B
# t3 = height of rectangle B

isIntersected:
#===================================================================

	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s7, 20($sp)

	add $s0, $a0, $a2
	addi $s0, $s0, -1	# subtract 1 because the pixel after the last one was incorrectly added above 
	add $s1, $a1, $a3
	addi $s1, $s1, -1
	add $s2, $t0, $t2
	addi $s2, $s2, -1
	add $s3, $t1, $t3
	addi $s3, $s3, -1

	li $v0, 1	# first assume they intersect
	slt $s7, $s0, $t0		# A's right x < B's left x 
	bne $s7, $zero, no_intersect
	nop
	slt $s7, $s2, $a0		# A's left x > B's right x
	bne $s7, $zero, no_intersect
	nop

	slt $s7, $s1, $t1		# A's bottom y < B's top y 
	bne $s7, $zero, no_intersect
	nop
	slt $s7, $s3, $a1		# A's top y > B's bottom y
	bne $s7, $zero, no_intersect
	nop
	j check_intersect_end
	nop

no_intersect:
	li $v0, 0

check_intersect_end:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s7, 20($sp)
	addi $sp, $sp, 24

	jr $ra
	nop

#---------------------------------------------------------------------------------------------------------------------
# Function: update the game screen objects according to the game data structures in MIPS code here

updateGameObjects:				
#===================================================================


	li $v0, 100

	# update game state numbers	
	li $a0, 14

	li $a1, 0	# Score number
	ori $a2, $s2, 0	
	syscall
	
	li $a1, 1	# level number
	ori $a2, $s3, 0	
	syscall

	li $a1, 2	# simple bomb available number
	ori $a2, $s4, 0	
	syscall

	li $a1, 3	# remote bomb available number
	ori $a2, $s5, 0	
	syscall



	# update ship
	li $a1, 4

	la $t0, ship
	lw $a2, 0($t0)
	lw $a3, 4($t0)
		
	li $a0, 12	# ship location			
	syscall
	
	li $a0, 11	# ship image index
	lw $a2, 8($t0)	
	syscall



	# update submarines
	li $a1, 5

	la $t6, submarines
	li $t7, 0
draw_submarine_loop:
	lw $a2, ($t6)
	lw $a3, 4($t6)
	li $a0, 12	# location	
	syscall

	li $a0, 11	# image index
	lw $a2, 8($t6)	
	syscall

draw_submarine_loop_continue:
	addi $a1, $a1, 1	
	addi $t7, $t7, 1 
	addi $t6, $t6, 20
	bne $t7, $s1, draw_submarine_loop
	nop


	
	# update dolphins
	la $t6, dolphins
	li $t7, 0
draw_dolphin_loop:
	lw $a2, ($t6)
	lw $a3, 4($t6)
	li $a0, 12	# location	
	syscall

	li $a0, 11	# image index
	lw $a2, 8($t6)	
	syscall

draw_dolphin_loop_continue:
	addi $a1, $a1, 1	
	addi $t7, $t7, 1 
	addi $t6, $t6, 20
	bne $t7, $s0, draw_dolphin_loop
	nop
		

	# update bombs
	la $t6, bombs
	li $s7, 6
	li $t7, 0
draw_bomb_loop:
	lw $a2, ($t6)
	lw $a3, 4($t6)
	li $a0, 12	# location	
	syscall

	li $a0, 11	# image index
	lw $a2, 8($t6)	
	syscall

draw_bomb_loop_continue:
	addi $a1, $a1, 1	
	addi $t7, $t7, 1 
	addi $t6, $t6, 20
	bne $t7, $s7, draw_bomb_loop
	nop
	
	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: get input character from keyboard, which is stored using Memory-Mapped Input Output (MMIO)
# return $v0: ASCII value of input character if input is available; otherwise the value zero

getInput:
#===================================================================
	addi $v0, $zero, 0

	lui $a0, 0xffff
	lw $a1, 0($a0)
	andi $a1,$a1,1
	beq $a1, $zero, noInput
	nop
	lw $v0, 4($a0)

noInput:	
	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: randomly change the sign (from positive to negative or vice versa) of $a0, and return the result in $a0
# $a0 = an integer
randomSignChange:
#===================================================================
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	
	addi $sp, $sp, -4	# preserve the original integer
	sw $a0, 0($sp)	

	li $a0, 2
	jal randnum
	nop

	lw $a0, 0($sp)		# restore the original integer
	addi $sp, $sp, 4

	beq $v0, $zero, no_sign_change
	nop
	li $a1, -1
	mult $a1, $a0
	mflo $a0

no_sign_change:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: set the seed of the random number generator to $a0
# $a0 = the seed number
setRandomSeed:
#===================================================================
	ori $a1, $a0, 0		
	li $v0, 40    
	li $a0, 1
	syscall

	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: generate a random number between 0 and ($a0 - 1) inclusively, and return it in $v0
# $a0 = range
randnum:
#===================================================================

	li $v0, 42
	ori $a1, $a0, 0
	li $a0, 1 
	syscall
	ori $v0, $a0, 0

	jr $ra
	nop

#----------------------------------------------------------------------------------------------------------------------
# Function: set the location, color and font of drawing the game state's output objects in the game screen
setGameStateOutput:				
#===================================================================

		
	li $v0, 100

	# score number's location
	li $a1, 0
	li $a0, 12
	li $a2, 154
	li $a3, 35				
	syscall

	# font (size 20, plain)
	li $a0, 16
	li $a2, 20
	li $a3, 0
	li $t0, 0				
	syscall

	# color
	li $a0, 15
	li $a2, 0x00404040   # dark gray				
	syscall


	# level number's location
	li $a1, 1
	li $a0, 12
	li $a2, 154
	li $a3, 69				
	syscall

	# font (size 20, plain)
	li $a0, 16
	li $a2, 20
	li $a3, 0
	li $t0, 0				
	syscall

	# color
	li $a0, 15
	li $a2, 0x00404040   # dark gray				
	syscall

	
	# Simple bomb available number's location
	li $a1, 2
	li $a0, 12
	li $a2, 487
	li $a3, 45				
	syscall

	# font (size 26, plain)
	li $a0, 16
	li $a2, 26
	li $a3, 0
	li $t0, 0				
	syscall

	# color
	li $a0, 15
	li $a2, 0x00ff00ff   # purple				
	syscall

	# Remote bomb available number's location
	li $a1, 3
	li $a0, 12
	li $a2, 638
	li $a3, 45				
	syscall

	# font (size 26, plain)
	li $a0, 16
	li $a2, 26
	li $a3, 0
	li $t0, 0				
	syscall

	# color
	li $a0, 15
	li $a2, 0x00ff00ff   # purple				
	syscall

	jr $ra
	nop
	
#----------------------------------------------------------------------------------------------------------------------
# Function: set the location, font and color of drawing the game-over string object (drawn once the game is over) in the game screen
setGameoverOutput:				
#===================================================================


	li $v0, 100	# gameover string
	addi $a1, $s0, 11	# 11 for 4 game states, 6 bombs, 1 ship 
	add $a1, $a1, $s1 

	li $a0, 13	# set object to game-over string
	la $a2, msg3				
	syscall
	
	# location
	li $a0, 12
	li $a2, 100
	li $a3, 250				
	syscall

	# font (size 40, bold, italic)
	li $a0, 16
	li $a2, 80
	li $a3, 1
	li $t0, 1				
	syscall


	# color
	li $a0, 15
	li $a2, 0x00ffff00   # yellow				
	syscall

	jr $ra
	nop
	
#----------------------------------------------------------------------------------------------------------------------
## Function: create a new game (the first step in the game creation)
createGame:
#===================================================================
	li $v0, 100	

	li $a0, 1
	li $a1, 800 
	li $a2, 600
	la $a3, title
	syscall

	#set game image array
	li $a0, 3
	la $a1, images
	syscall

	li $a0, 5
	li $a1, 0   #set background image index to 0
	syscall
 
	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
## Function: create the game screen objects
createGameObjects:
#===================================================================

	li $v0, 100	
	li $a0, 2
	addi $a1, $zero, 4   	# 4 game state outputs
	addi $a1, $a1, 1	# 1 ship
	add $a1, $a1, $s1	# s1 submarines 
	add $a1, $a1, $s0	# s0 dolphins
	addi $a1, $a1, 6   	# 6 bombs
	addi $a1, $a1, 1	# gameover output 
	syscall
 
	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
## Function: create and show the game screen
createGameScreen:
#===================================================================

	li $v0, 100   
	li $a0, 4
	syscall
	 
	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
## Function: redraw the game screen with the updated game screen objects
redrawScreen:
#===================================================================
	li $v0, 100   
	li $a0, 6
	syscall

	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
## Function: get the current time (in milliseconds from a fixed point of some years ago, which may be different in different program execution).    
# return $v0 = current time 
getCurrentTime:
#===================================================================
	li $v0, 30
	syscall				# this syscall also changes the value of $a1
	andi $v0, $a0, 0x3fffffff  	# truncated to milliseconds from some years ago

	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
## Function: pause execution for X milliseconds from the specified time T (some moment ago). If the current time is not less than (T + X), pause for only 1ms.    
# $a0 = specified time T (returned from a previous calll of getCurrentTime)
# $a1 = X amount of time to pause in milliseconds 
pauseExecution:
#===================================================================
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	add $a3, $a0, $a1

	jal getCurrentTime
	nop
	sub $a0, $a3, $v0

	slt $a3, $zero, $a0
	bne $a3, $zero, positive_pause_time
	nop
	li $a0, 1     # pause for at least 1ms

positive_pause_time:

	li $v0, 32	 
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	nop
#----------------------------------------------------------------------------------------------------------------------
