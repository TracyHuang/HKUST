#Name:
#ID:
#Email:
#Lab Section:
#Bonus -- left-movement key:     right-movement key:


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

############################
# Please add your code here#
############################






#---------------------------------------------------------------------------------------------------------------------
# Function: remove the destroyed submarines and dolphins from the screen

removeDestroyedObjects:				
#===================================================================

############################
# Please add your code here#
############################







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


	



	
#----------------------------------------------------------------------------------------------------------------------
# Function: read and handle the user's input

processInput:
#===================================================================

############################
# Please add your code here#
############################

	




#----------------------------------------------------------------------------------------------------------------------
# Function: move the ship, submarines and dolphins

moveShipSubmarinesDolphins:
#===================================================================

############################
# Please add your code here#
############################

	




#----------------------------------------------------------------------------------------------------------------------
# Function: move the bombs, and then remove those under the
# game screen and add them back to the available ones. 

moveBombs:
#===================================================================

############################
# Please add your code here#
############################


	
	




#----------------------------------------------------------------------------------------------------------------------
# Function: update the image index of any damaged or destroyed submarines and dolphins

updateDamagedImages:
#===================================================================

############################
# Please add your code here#
############################

	




	
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
