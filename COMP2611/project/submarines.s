#Name: Huang Tianwei
#ID: 20026141
#Email: twhuang@stu.ust.hk
#Lab Section: LAB 3
#Bonus -- left-movement key:  j   right-movement key:  k


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

	ori $s3, $zero, 1			# level = 1
	ori $s2, $zero, 0			# score = 0

	
	jal createGame				# create the game 

	#----- initialize game objects and information, and create game screen ---
	jal createGameObjects
	jal setGameStateOutput

	jal initgame				# initalize the first game level

	jal updateGameObjects
	jal createGameScreen
	#-------------------------------------------------------------------------
	
main1:
	jal getCurrentTime			# Step 1 of the game loop 
	ori $s6, $v0, 0    			# v1 keeps the iteration starting time

	jal removeDestroyedObjects		# Step 2 of the game loop
	jal processInput			# Step 3 of the game loop
	jal checkBombHits			# Step 4 of the game loop
	jal updateDamagedImages			# Step 5 of the game loop

	jal isLevelUp				# Step 6 of the game loop
	bne $v0, $zero, main2			# the current level is won

	jal moveShipSubmarinesDolphins		# Step 7 of the game loop	
	jal moveBombs				# Step 8 of the game loop

updateScreen:
	jal updateGameObjects			# Step 9 of the game loop
	jal redrawScreen

	ori $a0, $s6, 0				# Step 10 of the game loop
	li $a1, 30
	jal pauseExecution
	j main1
	
main2:	
	li $t0, 10				# the last level is 10
	beq $s3, $t0, main3 			# the last level and hence the whole game is won 
	addi $s3, $s3, 1			# increment level
	li $t0, 5
	div $s3, $t0
	mfhi $t0
	beq $t0, $zero, double_dolphin_num	# level no. is divisible by 5
	addi $s0, $s0, 3			# dolphin_num = dolphin_num + 3
	j main_continue
double_dolphin_num:
	sll $s0, $s0, 1				# dolphin_num = dolphin_num * 2
main_continue:
	addi $s1, $s0, 3			# submarine_num = dolphin_num + 3

	#----- re-initialize game objects and information for next level --------
	jal createGameObjects
	jal setGameStateOutput

	jal initgame				# initialize the next game level
	#-------------------------------------------------------------------------

	j updateScreen

main3: 
	jal setGameoverOutput			# GAME OVER!
	jal redrawScreen   
	j end_main

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
	slti $t4, $s0, 1
	bne $t4, $zero, setting3
	addi $s1, $s0, 3			# submarine_num = dolphin_num + 3
	j setting2

setting3:
	la $a0, msg1
	ori $v0, $zero, 4			# Invalid size
	syscall
	j setting1

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

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#---------------------------------------------------------------------------------------------------------------------
# Function: initalize to a new level
# Generate random location and speed for submarines and dolphins
# Set the image index of submarines and dolphins according to their own moving direction
# Set the Hit point of the submarines and dolphins
# Set the available number of the bombs
# Initialize the image index and speed of the bombs

initgame: 			
#===================================================================

addi $sp, $sp, -4
sw $ra, 0($sp)
li $t6, 0                    # used in the check_if_same process, represent the number of submarine checked
li $t7, 0                    # used in the check_if_same_dolphin process, represent the number of dolphin checked

la $t0, submarines
add $t2, $zero, $zero        # number of submarines that have been set
randomnum_loop: 
beq $t2, $s1, generate_location_dolphin
addi $a0, $zero, 720         # upper bound for random
jal randnum
sw $v0, 0($t0)               # set x coordinate
set_y_submarine: 
addi $a0, $zero, 250
jal randnum
addi $v0, $v0, 250
li $t6, 0
la $t5, submarines


check_if_same:
beq $t6, $t2, set_y_coodinate_submarine              # check if there is any other object with the same y coodinate
lw $t1, 4($t5)
beq $t1, $v0, set_y_submarine
addi $t6, $t6, 1
addi $t5, $t5, 20
j check_if_same

set_y_coodinate_submarine:
sw $v0, 4($t0)               # set y coordinate
addi $a0, $zero, 6
jal randomSignChange
sw $a0, 12($t0)              # set speed of submarine
bgt $a0, $zero, positive_direction
addi $t3, $zero, 4
sw $t3, 8($t0)               # set image index of submarine
j set_hitpoint
positive_direction:
addi $t3, $zero, 3
sw $t3, 8($t0)               # also set the image index of submarine
set_hitpoint:
addi $t3, $zero, 10
sw $t3, 16($t0)              # set hit point of submarine
addi $t0, $t0, 20
addi $t2, $t2, 1
j randomnum_loop

generate_location_dolphin:
la $t0, dolphins
add $t2, $zero, $zero        # number of dolphins that have been set
randomnum_loop_dolphin: 
beq $t2, $s0, set_bombs
addi $a0, $zero, 740
jal randnum
sw $v0, 0($t0)               # set x coordinate of dolphin
random_y_dolphin:
addi $a0, $zero, 250
jal randnum
addi $v0, $v0, 250
li $t6, 0
li $t7, 0
la $t5, submarines
check_if_same_dolphin:
beq $t6, $s1, check_same_dolphin
lw $t1, 4($t5)
beq $t1, $v0, random_y_dolphin 
addi $t6, $t6, 1
addi $t5, $t5, 20
j check_if_same_dolphin
la $t5, dolphins
check_same_dolphin:
beq $t7, $t2, set_y_dolphin
lw $t1, 4($t5)
beq $t1, $v0, random_y_dolphin
addi $t7, $t7, 1
addi $t5, $t5, 20
j check_same_dolphin

set_y_dolphin:
sw $v0, 4($t0)               # set y coordinate of dolphin
addi $a0, $zero, 5
jal randomSignChange
sw $a0, 12($t0)              # set speed of dolphin
bgt $a0, $zero, positive_direction_dophin
addi $t3,$zero, 9
sw $t3, 8($t0)               # set image index of dolphin
j set_hitpoint_dolphin
positive_direction_dophin:
addi $t3, $zero, 8
sw $t3, 8($t0)               # also set image index of dolphin
set_hitpoint_dolphin:
addi $t3, $zero, 20       
sw $t3, 16($t0)              # set hitpoint of dolphin
addi $t0, $t0, 20
addi $t2, $t2, 1
j randomnum_loop_dolphin

set_bombs:
addi $s4, $zero, 5           # max number of simple bombs
addi $s5, $zero, 1           # max number of remote bombs
la $t0, bombs
add $t2, $zero, $zero        # number of bombs that have been set
set_simple_bombs_loop:
beq $t2, $s4, set_remote_bombs
addi $t3, $zero, -1
sw $t3, 8($t0)               # set image index of bomb
addi $t3, $zero, 4
sw $t3, 12($t0)              # set speed of bomb
addi $t2, $t2, 1
addi $t0, $t0, 20
j set_simple_bombs_loop

set_remote_bombs:
addi $t4, $zero, -1
sw $t4, 8($t0)               # set image index of remote bomb
addi $t4, $zero, 4
sw $t4, 12($t0)              # set speed of remote bomb
addi $t4, $zero, -1
sw $t4, 16($t0)              # set the status of remote bomb to dessrted

lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#---------------------------------------------------------------------------------------------------------------------
# Function: remove the destroyed submarines and dolphins from the screen

removeDestroyedObjects:			
#===================================================================

la $t0, submarines
add $t2, $zero, $zero                             # number of submarines that have been checked
addi $t5, $zero, 7                                # index for destroyed submarine
remove_destroyed_submarines:
beq $t2, $s1, remove_destroyed_dolphins
lw $t4, 8($t0)                                    # get the image index
beq $t4, $t5, remove_submarine
addi $t0, $t0, 20
addi $t2, $t2, 1
j remove_destroyed_submarines
remove_submarine:
addi $t7, $zero, -1
sw $t7, 8($t0)
addi $t2, $t2, 1
j remove_destroyed_submarines

remove_destroyed_dolphins:
la $t0, dolphins
add $t2, $zero, $zero                             # number of dolphins that have been checked
addi $t5, $zero, 10                               # index for destroyed dolphin
remove_destroyed_dolphins_loop:
beq $t2, $s0, end
lw $t4, 8($t0)                                    # get the image index
beq $t4, $t5, remove_dolphin
addi $t0, $t0, 20
addi $t2, $t2, 1
j remove_destroyed_dolphins_loop
remove_dolphin:
addi $t7, $zero, -1
sw $t7, 8($t0)
addi $t2, $t2, 1
j remove_destroyed_dolphins_loop

end:
jr $ra

#---------------------------------------------------------------------------------------------------------------------
# Function: check any hits between an Activated bomb and a submarine or dolphin,
# and then handle the hits:
# change the hit submarine or dolphin's Hit point and change the score accordingly
# remove the bomb and add it back to the available ones

checkBombHits:				
#===================================================================
addiu $sp, $sp, -36
sw $t9, 32($sp)
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
		
CheckBombHitDone:
lw $t9, 32($sp)	
lw $s6, 28($sp)
lw $s5, 24($sp)
lw $s4, 20($sp)
lw $s3, 16($sp)
lw $s2, 12($sp)
lw $s1, 8($sp)
lw $s0, 4($sp)
lw $ra, 0($sp)


addiu $sp, $sp, 36
jr $ra

	
	
#----------------------------------------------------------------------------------------------------------------------
# Function: read and handle the user's input

processInput:
#===================================================================
addi $sp, $sp, -4
sw $ra, 0($sp)

jal getInput
li $t0, 113                                   # acsii value of " q "
li $t1, 49                                    # ascii value of " 1 "
li $t2, 50                                    # ascii value of " 2 "
li $t3, 101                                   # ascii value of " e "
bne $v0, $t0, second_condition

terminate_game:                               # action done when " q " is pressed
j end_main

second_condition:
bne $v0, $t1, third_condition
drop_simple_bomb:
beq $s4, $zero, end_processinput
la $t0, bombs
find_newest_unused_bomb:
lw $t1, 8($t0)
blt $t1, $zero, drop_simple_bomb_set
addi $t0, $t0, 20
j find_newest_unused_bomb 
drop_simple_bomb_set:            
la $t3, ship
lw $t4, 0($t3)
addi $t4, $t4, 65
sw $t4, 0($t0)         # set x coordinate of bomb
li $t4, 150
sw $t4, 4($t0)         # set y coordinate of bomb
li $t6, 11
sw $t6, 8($t0)         # set image index of bomb
addi $s4, $s4, -1      # one less simple bomb available
j end_processinput

third_condition:
bne $v0, $t2, fourth_condition


drop_remote_bomb:
beq $s5, $zero, end_processinput
la $t0, bombs
addi $t0, $t0, 100
li $t1, 12
sw $t1, 8($t0)         # set image index
la $t3, ship
lw $t4, 0($t3)
addi $t4, $t4, 65
sw $t4, 0($t0)         # set x coordinate of bomb
li $t4, 150
sw $t4, 4($t0)         # set y coordinate of bomb
li $t4, 0
sw $t4, 16($t0)
addi $s5, $s5, -1
j end_processinput

fourth_condition:
bne $v0, $t3, fifth_condition
activate_remote_bomb:
bne $s5, $zero, end_processinput
la $t0, bombs
addi $t0, $t0, 100
li $t1, 13
sw $t1, 8($t0)         # set image index
li $t1, 1
sw $t1, 16($t0) 
j end_processinput

fifth_condition:
li $t1, 106
bne $v0, $t1, sixth_condition
li $t9, 1
la $t0, ship
lw $t1, 0($t0)                                    # x coodinate of the ship
addi $t1, $t1, -4
sw $t1, 0($t0)
li $t5, 2
sw $t5, 8($t0) 
bgt $t1, $zero, end_processinput
li $t4, 0
sw $t4, 0($t0)
li $t4, 4
sw $t4, 12($t0)
li $t4, 1
sw $t4, 8($t0)
j end_processinput

sixth_condition:
li $t1, 107
bne $v0, $t1, end_processinput
li $t9, 1
la $t0, ship
lw $t1, 0($t0)
addi $t1, $t1, 4
sw $t1, 0($t0)
li $t4, 1
sw $t4, 8($t0)
li $t4, 639
blt $t1, $t4, end_processinput
li $t4, 639
sw $t4, 0($t0)
li $t4, -4
sw $t4, 12($t0)
li $t4, 2
sw $t4, 8($t0)


end_processinput:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#----------------------------------------------------------------------------------------------------------------------
# Function: move the ship, submarines and dolphins

moveShipSubmarinesDolphins:
#===================================================================
bne $t9, $zero, move_submarine
la $t0, ship
lw $t1, 0($t0)                                    # x coodinate of the ship
lw $t2, 12($t0)                                   # speed of the ship
lw $t3, 8($t0)                                    # image index of the ship
add $t1, $t1, $t2
ble $t1, $zero, touch_left_ship
addi $t4, $t1, -639
bge $t4, $zero, touch_right_ship
sw $t1, 0($t0)
j move_submarine

touch_left_ship:
li $t4, 0
sw $t4, 0($t0)
li $t4, 4
sw $t4, 12($t0)
li $t4, 1
sw $t4, 8($t0)
j move_submarine

touch_right_ship:
li $t4, 639
sw $t4, 0($t0)
li $t4, -4
sw $t4, 12($t0)
li $t4, 2
sw $t4, 8($t0)


move_submarine:
la $t0, submarines
li $t6, 0

move_loop_submarine:
lw $t1, 0($t0)                        # x coordinate of the submarine
lw $t2, 12($t0)                       # speed of the submarine
lw $t3, 8($t0)                        # image index of the submarine
ble $t3, $zero, next_submarine_move
add $t1, $t1, $t2
ble $t1, $zero, touch_left_submarine
li $t5, 719
bge $t1, $t5, touch_right_submarine
sw $t1, 0($t0)
j next_submarine_move

touch_left_submarine:
li $t7, 0
sw $t7, 0($t0)
li $t7, 6
sw $t7, 12($t0)
li $t7, 3
sw $t7, 8($t0)
j next_submarine_move

touch_right_submarine:
li $t7, 719
sw $t7, 0($t0)
li $t7, -6
sw $t7, 12($t0)
li $t7, 4
sw $t7, 8($t0)
j next_submarine_move

next_submarine_move:
addi $t0, $t0, 20
addi $t6, $t6, 1
blt $t6, $s1, move_loop_submarine


move_dolphin:
la $t0, dolphins
li $t6, 0                  # number of dolphins that have been moved

move_loop_dolphin:
lw $t1, 0($t0)             # x coordinate of the dolphin
lw $t2, 12($t0)            # speed of the dolphin
lw $t3, 8($t0)             # image index of the dolphin
ble $t3, $zero, next_dolphin_move
add $t1, $t1, $t2
ble $t1, $zero, touch_left_dolphin
addi $t5, $t1, -739
bge $t5, $zero, touch_right_dolphin
sw $t1, 0($t0)
j next_dolphin_move

touch_left_dolphin:
li $t4, 0
sw $t4, 0($t0)
li $t4, 5
sw $t4, 12($t0)
li $t4, 8
sw $t4, 8($t0)
j next_dolphin_move

touch_right_dolphin:
li $t4, 739
sw $t4, 0($t0)
li $t4, -5
sw $t4, 12($t0)
li $t4, 9
sw $t4, 8($t0)
j next_dolphin_move

next_dolphin_move:
addi $t0, $t0, 20
addi $t6, $t6, 1
blt $t6, $s0, move_loop_dolphin
	
jr $ra



#----------------------------------------------------------------------------------------------------------------------
# Function: move the bombs, and then remove those under the
# game screen and add them back to the available ones. 

moveBombs:
#===================================================================

############################
# Please add your code here#
############################
la $t0, bombs
li $t6, 569
move_simple_bombs:
li $t7, 0                                       # number of simple bombs that have been moved
move_simple_bomb_loop:
lw $t1, 8($t0)
blt $t1, $zero, next_bomb_move
lw $t1, 4($t0)
addi $t1, $t1, 4
bgt $t1, $t6, remove_simple_bomb
sw $t1, 4($t0)
j next_bomb_move
remove_simple_bomb:
li $t5, -1
sw $t5, 8($t0)
addi $s4, $s4, 1
next_bomb_move:
addi $t0, $t0, 20
addi $t7, $t7, 1
li $t2, 5
blt $t7, $t2, move_simple_bomb_loop
  
bne $s5, $zero, end_move_bomb	
la $t0, bombs
addi $t0, $t0, 100
lw $t1, 4($t0)
addi $t1, $t1, 4
bgt $t1, $t6, remove_remote_bomb
sw $t1, 4($t0)
j end_move_bomb
remove_remote_bomb:	
li $t5, -1
sw $t5, 8($t0)
addi $s5, $s5, 1
end_move_bomb:
jr $ra
#----------------------------------------------------------------------------------------------------------------------
# Function: update the image index of any damaged or destroyed submarines and dolphins

updateDamagedImages:
#===================================================================
la $t0, submarines
li $t7, 0                                                   # number of submarines that have been checked
check_damaged_submarine:
lw $t1, 8($t0)
blt $t1, $zero, next_submarine_damagecheck                        # check whether the submarine is already removed
lw $t1, 16($t0)
li $t2, 5
bgt $t1, $t2, next_submarine_damagecheck
beq $t1, $zero, destroyed_submarine_management
lw $t3, 12($t0)
blt $t3, $zero, left_damaged
li $t3, 5
sw $t3, 8($t0)
j next_submarine_damagecheck
left_damaged:
li $t3, 6
sw $t3, 8($t0)
j next_submarine_damagecheck
destroyed_submarine_management:
li $t3, 7
sw $t3, 8($t0)
next_submarine_damagecheck:
addi $t0, $t0, 20
addi $t7, $t7, 1
blt $t7, $s1, check_damaged_submarine

la $t0, dolphins
li $t7, 0                                                    # number of dolphins that have been checked
check_damaged_dolphin:
lw $t1, 8($t0)
blt $t1, $zero, next_dolphin_damage_check                    # check whether the submarine is already removed
lw $t1, 16($t0)
bne $t1, $zero, next_dolphin_damage_check
li $t2, 10
sw $t2, 8($t0)
next_dolphin_damage_check:
addi $t0, $t0, 20
addi $t7, $t7, 1
blt $t7, $s0, check_damaged_dolphin



jr $ra
	
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
	ori $v0, $zero, 0	# submarine has not been removed yet
	jr $ra

level_submarine_loop_continue:	
	addi $t7, $t7, 1 
	addi $t6, $t6, 20
	bne $t7, $s1, level_submarine_loop

	jr $ra

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
	slt $s7, $s2, $a0		# A's left x > B's right x
	bne $s7, $zero, no_intersect

	slt $s7, $s1, $t1		# A's bottom y < B's top y 
	bne $s7, $zero, no_intersect
	slt $s7, $s3, $a1		# A's top y > B's bottom y
	bne $s7, $zero, no_intersect
	j check_intersect_end

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
	
	jr $ra

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
	lw $v0, 4($a0)

noInput:	
	jr $ra

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

	lw $a0, 0($sp)		# restore the original integer
	addi $sp, $sp, 4

	beq $v0, $zero, no_sign_change
	li $a1, -1
	mult $a1, $a0
	mflo $a0

no_sign_change:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

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
#----------------------------------------------------------------------------------------------------------------------
## Function: create and show the game screen
createGameScreen:
#===================================================================

	li $v0, 100   
	li $a0, 4
	syscall
	 
	jr $ra
#----------------------------------------------------------------------------------------------------------------------
## Function: redraw the game screen with the updated game screen objects
redrawScreen:
#===================================================================
	li $v0, 100   
	li $a0, 6
	syscall

	jr $ra
#----------------------------------------------------------------------------------------------------------------------
## Function: get the current time (in milliseconds from a fixed point of some years ago, which may be different in different program execution).    
# return $v0 = current time 
getCurrentTime:
#===================================================================
	li $v0, 30
	syscall				# this syscall also changes the value of $a1
	andi $v0, $a0, 0x3fffffff  	# truncated to milliseconds from some years ago

	jr $ra
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
	sub $a0, $a3, $v0

	slt $a3, $zero, $a0
	bne $a3, $zero, positive_pause_time
	li $a0, 1     # pause for at least 1ms

positive_pause_time:

	li $v0, 32	 
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#----------------------------------------------------------------------------------------------------------------------
