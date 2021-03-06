package objects;

import sdg.Object;
import sdg.Sdg;
import sdg.atlas.Atlas;
import sdg.collision.Hitbox;
import sdg.graphics.Sprite;
import sdg.manager.Keyboard;
import sdg.components.Motion;
import sdg.components.Animator;
import sdg.manager.GamePad;
import kha.input.KeyCode;

class Player extends Object
{
	var sprite:Sprite;	
	var body:Hitbox;
	var motion:Motion;
	var animator:Animator;
	var onGround:Bool;
	var gamepad:GamePad;

	var py:Float;

	public function new(x:Float, y:Float):Void
	{
		super(x, y);

		py = y;
		
		sprite = new Sprite('Idle-1');
		graphic = sprite;

		setSizeAuto();
		body = new Hitbox(this);
		
		setupAnimations();
		
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.maxVelocity.x = 5;
		motion.acceleration.y = 0.3;
		addComponent(motion);
		
		onGround = false;

		gamepad = GamePad.get();
	}

	function setupAnimations()
	{
		var idleRegs = Atlas.getRegionsByIndex('Idle', 1, 10);
		var runRegs = Atlas.getRegionsByIndex('Run', 1, 10);		

		animator = new Animator();
		animator.addAnimation('idle', idleRegs);
		animator.addAnimation('run', runRegs);		

		addComponent(animator);

		animator.play('idle');
	}

	override public function update():Void
	{
		super.update();		

		motion.acceleration.x = 0;		

		if (Keyboard.isHeld(KeyCode.Left) || gamepad.leftAnalog.x < 0)
		{
			motion.acceleration.x = -0.7;
			sprite.flip.x = true;	
		}            
        else if (Keyboard.isHeld(KeyCode.Right) || gamepad.leftAnalog.x > 0)
		{		
			motion.acceleration.x = 0.7;
			sprite.flip.x = false;
		}

		if ((Keyboard.isPressed(KeyCode.Z) || Keyboard.isPressed(KeyCode.Up) || gamepad.isPressed(GamePad.B_CIRCLE)) && onGround)
		{
			motion.velocity.y = -6;
			onGround = false;
		}
		else if (Keyboard.isPressed(KeyCode.R))
		{
			onGround = false;
			setPosition(70, 120);
		}

		if (motion.velocity.x != 0 && animator.nameAnim != 'run')
		{			
			animator.play('run');
			graphic.y = -2;
		}
		else if (motion.velocity.x == 0 && animator.nameAnim != 'idle')
		{
			animator.play('idle');
			graphic.y = 0;
		}
		
		body.moveBy(motion.velocity.x, motion.velocity.y, 'collision');	

		if (y >= (py + 1))
		{
			onGround = false;
			py = y;
		}	

		if (x < -width)
			x = Sdg.gameWidth + x;
		else if (x > Sdg.gameWidth)
			x = x - Sdg.gameWidth;

		if (y > Sdg.gameHeight)
			y = -height;	
	}

	override public function moveCollideY(object:Object):Bool
	{
		if (motion.velocity.y > 0)
		{
			onGround = true;
			py = y;
		}

		motion.velocity.y = 0;

		return true;
	}	
}