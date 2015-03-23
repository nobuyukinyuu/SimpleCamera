#GLFW_WINDOW_RESIZABLE=True

Import mojo
Import SimpleCamera

Function Main()
	New Game()
End

Class Game Extends App
	
	Field b:= New Ball()
	Field cam:= New Camera()

	Field showDebug:Bool
	
	Const FILTER_AMOUNT:Float = 0.5
	Const PLAYFIELD_W = 2048
	Const PLAYFIELD_H = 2048
	Const TILE_SIZE = 32
	
	Method OnCreate()
		'SetUpdateRate(60)
		SetSwapInterval(1)
		
	
		cam.focalPoints.Push(b)
		cam.xRoam = 0.2
		cam.yRoam = 0.2
		cam.xRoamPad = 0.5
		cam.yRoamPad = 0.5
		cam.SetFilter(0.2, False)
	End
	
	Method OnUpdate()
		If KeyDown(KEY_RIGHT) Then b.x += 8
		If KeyDown(KEY_LEFT) Then b.x -= 8
		If KeyDown(KEY_UP) Then b.y -= 8
		If KeyDown(KEY_DOWN) Then b.y += 8
	
		If KeyHit(KEY_SPACE) Then showDebug = Not showDebug
		
		cam.Update()
	End

	Method OnRender()
		Cls()
		
		PushMatrix()
		cam.Focus()
		
		'Render playfield bg
		For Local y:Int = 0 Until PLAYFIELD_H Step TILE_SIZE
		For Local x:Int = 0 Until PLAYFIELD_W Step TILE_SIZE
			If ( (x / TILE_SIZE Mod 2 = 0) And (y / TILE_SIZE Mod 2 = 1)) Or ( (x / TILE_SIZE Mod 2 = 1) And (y / TILE_SIZE Mod 2 = 0))
				SetColor(32, 32, 32)
				DrawRect(x, y, TILE_SIZE, TILE_SIZE)
				SetColor(255, 255, 255)
			End If
		Next
		Next

		For Local y:Int = 0 Until PLAYFIELD_H Step TILE_SIZE
			If (y / TILE_SIZE Mod 2 = 0)
				SetColor(255, 0, 0)
			Else
				SetColor(255, 255, 255)
			End If
				DrawRect(0, y, TILE_SIZE, TILE_SIZE)
				DrawRect(PLAYFIELD_W - TILE_SIZE, y, TILE_SIZE, TILE_SIZE)
				SetColor(255, 255, 255)		
		Next
		For Local x:Int = 0 Until PLAYFIELD_W Step TILE_SIZE
			If (x / TILE_SIZE Mod 2 = 0)
				SetColor(255, 0, 0)
			Else
				SetColor(255, 255, 255)
			End If
				DrawRect(x, 0, TILE_SIZE, TILE_SIZE)
				DrawRect(x, PLAYFIELD_H - TILE_SIZE, TILE_SIZE, TILE_SIZE)
				SetColor(255, 255, 255)		
		Next
		
				
		DrawCircle(b.x, b.y, 16)
		
		PopMatrix()
		
		If showDebug Then cam.RenderDebug()
		DrawText("Press SPACEBAR to toggle cam boundary rendering", DeviceWidth() -8, DeviceHeight() -8, 1, 1)
	End

	Method Lerp:Float(x:Float, y:Float, amt:Float = 0.5)
		Return x + amt * (y - x)
	End Method	
End


Class Ball Implements FocalPoint
	Field x:Float = 128, y:Float = 128
	Field dx:Float, dy:Float

	'Necessary to implement FocalPoint
	Method FocalX:Float() Property
		Return x
	End Method
	Method FocalY:Float() Property
		Return y
	End Method
	Method FocalW:Float() Property
		Return 32
	End Method
	Method FocalH:Float() Property
		Return 32
	End Method
End Class