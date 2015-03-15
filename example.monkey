Import mojo
Import SimpleCamera

Function Main()
	New Game()
End

Class Game Extends App
	Field b:= New Ball()
	
	Method OnCreate()
		SetUpdateRate(60)
	
	End
	
	Method OnUpdate()
		
	End

	Method OnRender()
		Cls()
		
	End

End


Class Ball Implements FocalPoint


	'Necessary to implement FocalPoint
	Method FocalX:Float() Property
	End Method
	Method FocalY:Float() Property
	End Method
	Method FocalW:Float() Property
	End Method
	Method FocalH:Float() Property
	End Method
End Class