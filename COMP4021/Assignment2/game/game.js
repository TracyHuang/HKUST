// The point and size class used in this program
function Point(x, y) {	
    this.x = (x)? parseFloat(x) : 0.0;
    this.y = (y)? parseFloat(y) : 0.0;
}

function Size(w, h) {
    this.w = (w)? parseFloat(w) : 0.0;
    this.h = (h)? parseFloat(h) : 0.0;
}

// Helper function for checking intersection between two rectangles
function intersect(pos1, size1, pos2, size2) {
    return (pos1.x < pos2.x + size2.w && pos1.x + size1.w > pos2.x &&
            pos1.y < pos2.y + size2.h && pos1.y + size1.h > pos2.y);
}


// The player class used in this program
function Player() {
    this.node = svgdoc.getElementById("player");
    this.position = PLAYER_INIT_POS;
    this.motion = motionType.NONE;
	this.direction = directionType.RIGHT;
    this.verticalSpeed = 0;
}

function Bullet() {
    this.node = null;
    this.position = null;
    this.motion = motionType.NONE;

}


function Monster() {
    this.node = null;
    this.direction = null;
    this.speed = 0;
    this.motion = motionType.NONE;
}

Player.prototype.isOnPlatform = function() {
    var platforms = svgdoc.getElementById("platforms");
    for (var i = 0; i < platforms.childNodes.length; i++) {
        var node = platforms.childNodes.item(i);
        if (node.nodeName != "rect") continue;

        var x = parseFloat(node.getAttribute("x"));
        var y = parseFloat(node.getAttribute("y"));
        var w = parseFloat(node.getAttribute("width"));
        var h = parseFloat(node.getAttribute("height"));

        if (((this.position.x + PLAYER_SIZE.w > x && this.position.x < x + w) ||
             ((this.position.x + PLAYER_SIZE.w) == x && this.motion == motionType.RIGHT) ||
             (this.position.x == (x + w) && this.motion == motionType.LEFT)) &&
            this.position.y + PLAYER_SIZE.h == y) return true;
    }
    if (this.position.y + PLAYER_SIZE.h == SCREEN_SIZE.h) return true;

    return false;
}

Player.prototype.collidePlatform = function(position) {
    var platforms = svgdoc.getElementById("platforms");
    for (var i = 0; i < platforms.childNodes.length; i++) {
        var node = platforms.childNodes.item(i);
        if (node.nodeName != "rect") continue;

        var x = parseFloat(node.getAttribute("x"));
        var y = parseFloat(node.getAttribute("y"));
        var w = parseFloat(node.getAttribute("width"));
        var h = parseFloat(node.getAttribute("height"));
        var pos = new Point(x, y);
        var size = new Size(w, h);

        if (intersect(position, PLAYER_SIZE, pos, size)) {
            position.x = this.position.x;
            if (intersect(position, PLAYER_SIZE, pos, size)) {
                if (this.position.y >= y + h)
                    position.y = y + h;
                else
                    position.y = y - PLAYER_SIZE.h;
                this.verticalSpeed = 0;
            }
        }
    }
}

Player.prototype.collideScreen = function(position) {
    if (position.x < 0) position.x = 0;
    if (position.x + PLAYER_SIZE.w > SCREEN_SIZE.w) position.x = SCREEN_SIZE.w - PLAYER_SIZE.w;
    if (position.y < 0) {
        position.y = 0;
        this.verticalSpeed = 0;
    }
    if (position.y + PLAYER_SIZE.h > SCREEN_SIZE.h) {
        position.y = SCREEN_SIZE.h - PLAYER_SIZE.h;
        this.verticalSpeed = 0;
    }
}


//
// Below are constants used in the game
//
var PLAYER_SIZE = new Size(60, 60);         // The size of the player
var SCREEN_SIZE = new Size(900, 600);       // The size of the game screen
var PLAYER_INIT_POS  = new Point(0, 480);     // The initial position of the player
var POKEBALL_SIZE = new Size(40, 40);

var MOVE_DISPLACEMENT = 7;                  // The speed of the player in motion
var JUMP_SPEED = 30;                        // The speed of the player jumping
var VERTICAL_DISPLACEMENT = 2;              // The displacement of vertical speed

var GAME_INTERVAL = 25;                     // The time interval of running the game

var MONSTER_SIZE = new Size(90, 60);

//
// Variables in the game
//
var motionType = {NONE:0, LEFT:1, RIGHT:2, UP:3}; // Motion enum
var directionType = {LEFT:0, RIGHT:1};
var svgdoc = null;                          // SVG root document node
var player = null;                          // The player object
var gameInterval = null;                    // The interval
var zoom = 1.0;                             // The zoom level of the screen
var BULLET_SIZE = new Size(20, 20); // The size of a bullet
var BULLET_SPEED = 3.0;            // The speed of a bullet
                                    //  = pixels it moves each game loop
var SHOOT_INTERVAL = 200.0;         // The period when shooting is disabled
var canShoot = true;                // A flag indicating whether the player can shoot a bullet
var score = 0;
var max_monster = 6;
var max_pokeball = 8;
//var current_monster = 0;
var monster_speed = 3;
var monster_array = new Array();
var hit_time = 0;
var unhurtable = false;
var player_name = "Anonymous";
var time = 120;
var timeInterval;
var bomb_left = 8;
var hMoveLeft = true;
var vMoveDown = false;
var cheat = false;
var left_pokeball = 8;
var level = 1;
//
// The load function for the SVG document
//

function zoomModeOn() {
    zoom = 2.0;
}

function getUserName() {
    
    player_name = prompt("Please enter your name:", player_name);
    if (player_name == null || player_name == "") {
        player_name = "Anonymous";
    }

}

function intersectPlatforms(pos, size) {
            var platforms = svgdoc.getElementById("platforms");
            for (var i = 0; i < platforms.childNodes.length; i++) {
                var node = platforms.childNodes.item(i);
                if (node.nodeName != "rect") continue;

                var platform_x = parseFloat(node.getAttribute("x"));
                var platform_y = parseFloat(node.getAttribute("y"));
                var platform_w = parseFloat(node.getAttribute("width"));
                var platform_h = parseFloat(node.getAttribute("height"));
                var platform_pos = new Point(platform_x, platform_y);
                var platform_size = new Size(platform_w, platform_h);
                
                if (intersect(pos, size, platform_pos, platform_size)) {
                   return true;
                    }
               }
               return false;
}

function createPokeballs() {
    var pokeballs = svgdoc.getElementById("pokeballs");
    for (var i = 0; i < max_pokeball; i++) {
        var pokeball_id = "pokeball" + i;
        var x;
        var y;
        while (true) {
            x = Math.floor(Math.random() * 840);
            y = Math.floor(Math.random() * 480);
            var pos = new Point(x, y);
                if(!intersectPlatforms(pos, POKEBALL_SIZE)) {
                               break;
                }
            }
            var pokeball = svgdoc.createElementNS("http://www.w3.org/2000/svg", "use");
            pokeball.setAttributeNS("http://www.w3.org/1999/xlink", "xlink:href", "#pokeball");
            pokeball.setAttribute("x", x);
            pokeball.setAttribute("y", y);
            pokeballs.appendChild(pokeball);
        }
}


function load(evt) {
    
    // Set the root node to the global variable
    svgdoc = evt.target.ownerDocument;


    //play the background music
    //alert(document.getElementById("background_music"));
    (svgdoc.getElementById("background_music")).play();
    
    //add monsters and set locations for them
    for (var i = 0; i < max_monster; i++) {
        var x = Math.floor(Math.random() * 570 + 240);
        var y = Math.floor(Math.random() * 300);
        addMonster(x, y);
       
        monster_array[i] = new Point(x, y);
    }
   
    // Attach keyboard events
    svgdoc.documentElement.addEventListener("keydown", keydown, false);
    svgdoc.documentElement.addEventListener("keyup", keyup, false);

    // Remove text nodes in the 'platforms' group
    cleanUpGroup("platforms", true);

    // Create the player
    player = new Player();

    //attach name for player
    var name = svgdoc.createElementNS("http://www.w3.org/2000/svg", "text");
    name.setAttribute("style", "font-size:10px");
    name.textContent = player_name;
    svgdoc.getElementById("player").appendChild(name);


    //create pokeballs
    createPokeballs();

    //add disappearing platforms
    addSpecialPlatform(120, 330, 120, 30, 0);
    addSpecialPlatform(180, 450, 120, 30, 1);
    addSpecialPlatform(830, 390, 70, 30, 2);

    // Start the game interval
    gameInterval = setInterval("gamePlay()", GAME_INTERVAL);
    timeInterval = setInterval("updateTime()", 1000);
}


//
// This function removes all/certain nodes under a group
//
function cleanUpGroup(id, textOnly) {
    var node, next;
    var group = svgdoc.getElementById(id);
    node = group.firstChild;
    while (node != null) {
        next = node.nextSibling;
        if (!textOnly || node.nodeType == 3) // A text node
            group.removeChild(node);
        node = next;
    }
}


//
// This is the keydown handling function for the SVG document
//
function keydown(evt) {
    var keyCode = (evt.keyCode)? evt.keyCode : evt.getKeyCode();

    switch (keyCode) {
        case "A".charCodeAt(0):
            player.motion = motionType.LEFT;
            break;

        case "D".charCodeAt(0):
            player.motion = motionType.RIGHT;
            break;
			

        // Add your code here
        case "W".charCodeAt(0):
			player.motion = motionType.UP;
			if (player.isOnPlatform()) {
			    player.verticalSpeed = JUMP_SPEED;	
			}
			break;
		
		//shoot bullet	
		case 32: // spacebar = shoot
        if (canShoot) shootBullet();
        break;

        //cheat mode
    case "C".charCodeAt(0):
        if (cheat) {
            cheat = false;
        }
        else {
            cheat = true;
        }
        break;

		default:
		break;	

    }
}


//
// This is the keyup handling function for the SVG document
//
function keyup(evt) {
    // Get the key code
    var keyCode = (evt.keyCode)? evt.keyCode : evt.getKeyCode();

    switch (keyCode) {
        case "A".charCodeAt(0):
            if (player.motion == motionType.LEFT) player.motion = motionType.NONE;
            break;

        case "D".charCodeAt(0):
            if (player.motion == motionType.RIGHT) player.motion = motionType.NONE;
            break;
		
		case "W".charCodeAt(0):
			if (player.motion == motionType.UP) player.motion = motionType.NONE;
			player.verticalSpeed = 0;
			break;
			
		default:
		break;
    }
}


//
// This function updates the position and motion of the player in the system
//
function gamePlay() {

    
	collisionDetection();
	
    // Check whether the player is on a platform
    var isOnPlatform = player.isOnPlatform();
    
    // Update player position
    var displacement = new Point();

    // Move left or right
    if (player.motion == motionType.LEFT)
	{
        displacement.x = -MOVE_DISPLACEMENT;
		if(player.direction	== directionType.RIGHT)
		{
				changeDirection();
				player.direction = directionType.LEFT;
		}
	}
    if (player.motion == motionType.RIGHT)
    {
		displacement.x = MOVE_DISPLACEMENT;
		if(player.direction == directionType.LEFT)
		{
		    changeDirection();
			player.direction = directionType.RIGHT;
		}
	}

    // Fall
    if (!isOnPlatform && player.verticalSpeed <= 0) {
        displacement.y = -player.verticalSpeed;
        player.verticalSpeed -= VERTICAL_DISPLACEMENT;
    }

    // Jump
    if (player.verticalSpeed > 0) {
        displacement.y = -player.verticalSpeed;
        player.verticalSpeed -= VERTICAL_DISPLACEMENT;
        if (player.verticalSpeed <= 0)
            player.verticalSpeed = 0;
    }

    // Get the new position of the player
    var position = new Point();
    position.x = player.position.x + displacement.x;
    position.y = player.position.y + displacement.y;

    // Check collision with platforms and screen
    player.collidePlatform(position);
    player.collideScreen(position);

    // Set the location back to the player object (before update the screen)
    player.position = position;

    //disappearing platform check
    disappearingPlatformsChange();

    movePlatforms();
	moveBullets();
	moveMonsters();
    updateScreen();
}


//
// This function updates the position of the player's SVG object and
// set the appropriate translation of the game screen relative to the
// the position of the player
//
function updateScreen() {

	
    // Transform the player
    player.node.setAttributeNS(null, "transform", "translate(" + player.position.x + "," + player.position.y + ")");
     
    // Calculate the scaling and translation factors
    var tx = 0;
    var ty = 0;

    if ((player.position.x + PLAYER_SIZE.w / 2) < SCREEN_SIZE.w / zoom / 2)
        tx = 0;
    else if ((player.position.x + PLAYER_SIZE.w / 2) > (SCREEN_SIZE.w - SCREEN_SIZE.w / zoom / 2))
        tx = -(SCREEN_SIZE.w - SCREEN_SIZE.w / zoom);
    else
        tx = -player.position.x - PLAYER_SIZE.w / 2 + SCREEN_SIZE.w / zoom / 2;


    if ((player.position.y + PLAYER_SIZE.h / 2) < SCREEN_SIZE.h / zoom / 2)
        ty = 0;
    else if ((player.position.y + PLAYER_SIZE.h / 2) > (SCREEN_SIZE.h - SCREEN_SIZE.h / zoom / 2))
        ty = -(SCREEN_SIZE.h - SCREEN_SIZE.h / zoom);
    else
        ty = -player.position.y - PLAYER_SIZE.h / 2 + SCREEN_SIZE.h / zoom / 2;


    var game_area = svgdoc.getElementById("game_screen");
    game_area.setAttribute("transform", "scale(" + zoom + ")" + "translate(" + tx + "," + ty + ")");

}


function movePlatforms() {
    var hMovePlatform = svgdoc.getElementById("rect5");
    var x = parseInt(hMovePlatform.getAttribute("x"));
    if (hMoveLeft) {
        x -= 1
        if (x == 180) hMoveLeft = false;
    }
    else {
        x += 1;
        if (x == 240) hMoveLeft = true;
    }
    hMovePlatform.setAttribute("x", x);

    var vMovePlatform = svgdoc.getElementById("rect14");
    var y = parseInt(vMovePlatform.getAttribute("y"));
    if (vMoveDown) {
        y += 1
        if (y == 210) vMoveDown = false;
    }
    else {
        y -= 1;
        if (y == 90) vMoveDown = true;
    }
    vMovePlatform.setAttribute("y", x);

}

function addMonster(x, y) {
    
    var monster = svgdoc.createElementNS("http://www.w3.org/2000/svg", "use");
    var group = svgdoc.createElementNS("http://www.w3.org/2000/svg", "g");
    svgdoc.getElementById("monsters").appendChild(group);
    group.appendChild(monster);
    monster.setAttributeNS(null, "x", 0);
    monster.setAttributeNS(null, "y", 0);
    group.setAttributeNS(null, "transform", "translate(" + x + "," + y + ")"); 
    //var translate = "translate(" + x + "," + y + ")";
	//group.setAttributeNS(null, "transform", translate);
	
	monster.setAttributeNS("http://www.w3.org/1999/xlink", "xlink:href", "#monster");
	//var animation = svgdoc.createElementNS("http://www.w3.org/2000/svg", "animateMotion");
	//animation.setAttribute("path", "M0,0 ");
	//monster.appendChild(animation);
    monster.setAttribute("class", "left");
}


function moveMonsters() {
    var monsters = svgdoc.getElementById("monsters");
    
    for (var i = 0; i < monsters.childNodes.length; i++) {
        var node = monsters.childNodes.item(i);  //group
        if (node) {
            var monster = node.childNodes.item(0);
            var diff_x;
            if (monster.getAttribute("class") == "right") {
                diff_x = Math.ceil(Math.random() * monster_speed);
            }
            else if(monster.getAttribute("class") == "left") {
                diff_x = -Math.ceil(Math.random() * monster_speed);
            }
            var diff_y = Math.random() * 3  - 1.5;
            
            
            var x = monster_array[i].x + diff_x;
            var y = monster_array[i].y + diff_y;
            
           
            
            if (y < 0) y = -y;
            if (y > 540) {
                y = 1080 - y;
            }
            if (x <= 10) {
                //var transform_to_origin = "translate(" + (-parseFloat(node.getAttribute("x"))) + ", 0)";
                if (monster.getAttribute("transform") != null) {
                    monster.setAttributeNS(null, "transform", "translate(90, 0) scale(-1, 1) " + monster.getAttribute("transform"));
                }
                else {
                    monster.setAttributeNS(null, "transform", "translate(90, 0) scale(-1, 1) ");
                }
                 monster.setAttribute("class", "right");
                x = 15;
            }
            if (x > 810) {
                //var transform_to_origin = "translate(" + (-parseFloat(node.getAttribute("x"))) + ", 0)";

                if (monster.getAttribute("transform") != null) {
                    monster.setAttributeNS(null, "transform", "translate(90, 0) scale(-1, 1) " + monster.getAttribute("transform"));
                }
                else {
                    monster.setAttributeNS(null, "transform", "translate(90, 0) scale(-1, 1) ");
                }
                monster.setAttribute("class", "left");
                x = 800;
            }

            monster_array[i] = new Point(x, y);
            node.setAttribute("transform", "translate(" + x + "," + y +")");
             //node.setAttribute("x", x);
             //node.setAttribute("y", y);
        }
    }
}


function shootBullet() {

    if (parseInt(bomb_left) != 0) {

        svgdoc.getElementById("shoot_music").play();
        setTimeout("svgdoc.getElementById('shoot_music').pause()", 1000);
        // Disable shooting for a short period of time
        canShoot = false;
        setTimeout("canShoot=true", SHOOT_INTERVAL);
        bomb_left--;
        svgdoc.getElementById("bomb_left").textContent = bomb_left;

        // Create the bullet by createing a use node
        var bullet = new Bullet();
        bullet.node = svgdoc.createElementNS("http://www.w3.org/2000/svg", "use");
        svgdoc.getElementById("bullets").appendChild(bullet.node);

        // Calculate and set the position of the bullet
        if (player.direction == directionType.RIGHT) {
            bullet.node.setAttribute("x", player.position.x + 60);
        }
        else if (player.direction == directionType.LEFT) {
            bullet.node.setAttribute("x", player.position.x - 20);
        }
        bullet.node.setAttribute("y", player.position.y + 20);
        //bullet.position = Point(parseFloat(player.position.x) + 60 , parseFloat(player.position.y) + 20);
        //bullet.node.setAttributeNS(null, "transform", "translate(" + bullet.position.x + "," + bullet.position.y +")");

        // Set the href of the use node to the bullet defined in the defs node
        bullet.node.setAttributeNS("http://www.w3.org/1999/xlink", "xlink:href", "#bullet");

        //set bullet motionType
        if (player.direction == directionType.LEFT) {
            bullet.node.setAttribute("class", "left");
        }
        else if (player.direction == directionType.RIGHT) {
            bullet.node.setAttribute("class", "right");
        }

        // Append the bullet to the bullet group
        //svgdoc.getElementById("bullets").appendChild(bullet);
    }  
}



function moveBullets() {
    // Go through all bullets
    var bullets = svgdoc.getElementById("bullets");
    for (var i = 0; i < bullets.childNodes.length; i++) {
        var node = bullets.childNodes.item(i);

        // Update the position of the bullet
		var displacement = 0;
		if( node.getAttribute("class") == "right")
		{
			displacement = BULLET_SPEED;
		}
		else if( node.getAttribute("class") == "left")
		{
			displacement = - BULLET_SPEED;	
		}
		else
		{
			displacement = 0;	
		}
		node.setAttribute("x", parseInt(node.getAttribute("x")) + displacement);
        //node.setAttributeNS(null, "transform", "translate(" + node.position.x + ", " + node.position.y +")");

        // If the bullet is not inside the screen delete it from the group
        // As the y never changes, we only need to check x
		if ( parseFloat(node.getAttribute("x")) >= 900 || parseFloat(node.getAttribute("x")) <= 10)
		{
			node.parentNode.removeChild(node);	
		}
    }
}



function collisionDetection() {
    // Check whether the player collides with a monster
    if (!cheat) {
        var monsters = svgdoc.getElementById("monsters");
        for (var i = 0; i < monsters.childNodes.length; i++) {
            var monster = monsters.childNodes.item(i);

            // For each monster check if it overlaps with the player
            // if yes, stop the game
            var monster_point = new Point(monster_array[i].x + 10, monster_array[i].y + 10);
            var monster_size = new Size(70, 40);
            if (intersect(player.position, PLAYER_SIZE, monster_point, monster_size) && !unhurtable) {
                updateScore(-5);
                hit_time++;
                if (hit_time == 1) {
                    svgdoc.getElementById("pikachu").setAttribute("opacity", "0.6");
                    unhurtable = true;
                    setTimeout("unhurtable = false", 3000);
                }
                else if (hit_time == 2) {
                    stopGame();
                }
            }
        }
    }

// Check whether a bullet hits a monster

var bullets = svgdoc.getElementById("bullets");
var monsters = svgdoc.getElementById("monsters");
    for (var i = 0; i < bullets.childNodes.length; i++) {
        var bullet = bullets.childNodes.item(i);
        var bullet_point = new Point(bullet.getAttribute("x"), bullet.getAttribute("y"))
		// For each bullet check if it overlaps with any monster
        // if yes, remove both the monster and the bullet
        for (var j = 0; j < monsters.childNodes.length; j ++) {
			var monster = monsters.childNodes.item(j);
			//var monster_point = new Point(monster.getAttribute("x"), monster.getAttribute("y"));
			
			if(intersect(monster_array[j], MONSTER_SIZE, bullet_point, BULLET_SIZE)) {
			    svgdoc.getElementById("monsterdie_music").play();
                setTimeout("svgdoc.getElementById('monsterdie_music').pause()", 1000);
			    monster.parentNode.removeChild(monster);
			    monster_array[j] = new Point(-1, -1);
			    bullet.parentNode.removeChild(bullet);
			    if (zoom == 2.0) {
			        updateScore(30);
			    }
			    else {
			        updateScore(10);
			    }
				break;	
			}
		}
    }

//check whether player hits a pokeball


    var pokeballs = svgdoc.getElementById("pokeballs");
    for (var i = 0; i < pokeballs.childNodes.length; i ++) {
        var pokeball = pokeballs.childNodes.item(i);
        
        var x = pokeball.getAttribute("x");
        var y = pokeball.getAttribute("y");
        var pos = new Point(x, y);
        if (intersect(player.position, PLAYER_SIZE, pos, POKEBALL_SIZE)) {
            if (zoom == 2.0) {
                updateScore(20);
            }
            else {
                updateScore(10);
            }
            pokeball.parentNode.removeChild(pokeball);
            left_pokeball--;
            
        }

    }


    //check whether player has gone to the door (only check this when player has gone through all pokeballs)
    if (left_pokeball == 0) {
        var doorPos = new Point(680, 0);
        var doorSize = new Size(60, 60);
        if (intersect(player.position, PLAYER_SIZE, doorPos, doorSize)) {
            svgdoc.getElementById("levelup_music").play();
            setTimeout("svgdoc.getElementById('levelup_music').pause()", 1000);
            restartGame(parseInt(level) + 1);
        }
    }

}


function changeDirection() {
	//var trans = "translate(-" + obj.getAttribute("x") + ", -" + obj.getAttribute("y") +")";
	//var transBack = "translate(" + obj.getAttribute("x") + ", " + obj.getAttribute("y") +")"
	var pikachu = svgdoc.getElementById("pikachu");
	var originalTransform = pikachu.getAttribute("transform");
	pikachu.setAttributeNS(null, "transform", "translate(60, 0) scale(-1, 1) " + originalTransform);	
}


function removeStartScreen() {
//remove start_screen
var startScreen = svgdoc.getElementById("start_screen");
startScreen.parentNode.removeChild(startScreen);
}


function updateScore(diff) {
    if (diff >= 0) {
        diff *= parseInt(level);
    }
	
    score += diff;
    svgdoc.getElementById("score").textContent = score;
}

function updateTime() {
    time--;
    svgdoc.getElementById("time_left").textContent = time;
    if (time == 0) {
        clearInterval(timeInterval);
        stopGame();
    }
}



function stopGame() {
    svgdoc.getElementById("playerdie_music").play();
    setTimeout("svgdoc.getElementById('playerdie_music').pause()", 1000);
    clearInterval(gameInterval);
    clearInterval(timeInterval);
  
    var record = new ScoreRecord(player_name, score); 
    table = getHighScoreTable();
    for (var i = 0; i < table.length; i++) {
        if (parseInt(table[i].score) < parseInt(score))
            break;
    }
    table.splice(i, 0, record);
    
    
    setHighScoreTable(table);
    showHighScoreTable(table);
    var node = svgdoc.getElementById("gameover_screen");
    node.style.setProperty("visibility", "visible", null);
}


function addSpecialPlatform(x, y, width, height, index) {
    var platforms = svgdoc.getElementById("platforms");
    var newPlatform;
    // Create a new rect element
    newPlatform = svgdoc.createElementNS("http://www.w3.org/2000/svg", "rect");

    // Set the various attributes of the line
    newPlatform.setAttribute("x", x);
    newPlatform.setAttribute("y", y);
    newPlatform.setAttribute("width", width);
    newPlatform.setAttribute("height", height);
    newPlatform.setAttribute("id", "disappearing_platform" + index);
    newPlatform.setAttribute("type", "disappearing");
    newPlatform.setAttribute("style", "fill:#00ffff;opacity:1");   

    // Add the new platform to the end of the group
    platforms.appendChild(newPlatform);

}

function disappearingPlatformsChange() {
    var platforms = svgdoc.getElementById("platforms");
    var playerX = player.position.x;
    var playerY = player.position.y;

    for (var i = 0; i < platforms.childNodes.length; i++) {
        var platform = platforms.childNodes.item(i);
       
        if (platform.nodeName == "rect" && platform.getAttribute("type") == "disappearing") {
        var platformOpacity = parseFloat(platform.style.getPropertyValue("opacity"));
        var platformX = parseFloat(platform.getAttribute("x"));
        var platformY = parseFloat(platform.getAttribute("y"));
        var platformWidth = parseFloat(platform.getAttribute("width"));
              if (playerX >= platformX && platformX <= platformX + platformWidth && playerY == platformY - 60) {
                platformOpacity -= 0.1;
                platform.style.setProperty("opacity", platformOpacity, null);
                if (platformOpacity == 0) {
                    platforms.removeChild(platform);
                }
            }
        }
    }
}


function restartGame(goto_level) {
    clearInterval(gameInterval);
    clearInterval(timeInterval);

    if (parseInt(goto_level) == 1) {
        svgdoc.getElementById("gameover_screen").style.setProperty("visibility", "hidden", null);
        updateScore(-parseInt(score));
    }
    else {
        updateScore(100);               // the update function will multiple positive addition by level
        if (zoom == 2.0) {
            updateScore(parseInt(svgdoc.getElementById("time_left").textContent) * 2);
        }
        else {
            updateScore(parseInt(svgdoc.getElementById("time_left").textContent));
        }
    }
    svgdoc.getElementById("pikachu").setAttribute("opacity", "1.0");
    level = parseInt(goto_level);
    time = 120;
    hit_time = 0;
    max_pokeball = 4 + parseInt(level) * 4;
    left_pokeball = max_pokeball;
    svgdoc.getElementById("time_left").textContent = time;
    
    
    svgdoc.getElementById("level").textContent = level;
    bomb_left = 8;
    unhurtable = false;
    svgdoc.getElementById("bomb_left").textContent = bomb_left;

    //remove all monsters and bullets and pokeballs
    removeAll();

    //reset monsters
    max_monster = 2 + parseInt(level) * 4;
    
    for (var i = 0; i < max_monster; i++) {
        var x = Math.floor(Math.random() * 570 + 240);
        var y = Math.floor(Math.random() * 300);
        addMonster(x, y);
       
        monster_array[i] = new Point(x, y);
    }

    

    // Remove text nodes in the 'platforms' group
    cleanUpGroup("platforms", true);

    // Create the player
    if (player.direction == directionType.LEFT) {
        changeDirection();
    }
    player = new Player();

    //attach name for player
    /*
    var name = svgdoc.createElementNS("http://www.w3.org/2000/svg", "text");
    name.setAttribute("style", "font-size:10px");
    name.textContent = player_name;
    svgdoc.getElementById("player").appendChild(name);
    */

    //create pokeballs
    createPokeballs();

    //add disappearing platforms
    if(!svgdoc.getElementById("disappearing_platform0")) {
    addSpecialPlatform(120, 330, 120, 30, 0);
}
    if (!svgdoc.getElementById("disappearing_platform1")) {
    addSpecialPlatform(180, 450, 120, 30, 1);
}
    if (!svgdoc.getElementById("disappearing_platform2")) {
    addSpecialPlatform(830, 390, 70, 30, 2);
}

    // Start the game interval
    gameInterval = setInterval("gamePlay()", GAME_INTERVAL);
    timeInterval = setInterval("updateTime()", 1000);


}


function removeAll() {
    //remove all monsters and bullets and pokeballs
    /*
    alert(monsters.childNodes.length);
    for (var i = 0; i < monsters.childNodes.length; i++) {
        var monster = monsters.childNodes.item(i);
        monster.parentNode.removeChild(monster);
    }
    */
    var monsters = svgdoc.getElementById("monsters");
    while (monsters.firstChild) {
        monsters.removeChild(monsters.firstChild);
    }

    var bullets = svgdoc.getElementById("bullets");
    while (bullets.firstChild) {
        bullets.removeChild(bullets.firstChild);
    }

    var pokeballs = svgdoc.getElementById("pokeballs");
    while (pokeballs.firstChild) {
        pokeballs.removeChild(pokeballs.firstChild);
    }

}