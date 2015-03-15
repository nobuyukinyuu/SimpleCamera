Import mojo
Import focalpoint

Class Camera
	Field x:Float, y:Float
	Field focalPoints:= New Stack<FocalPoint>
	
	Field xConstraint:Float, yConstraint:Float
	Field xConstraintPad:Float, yConstraintPad:Float
	Field zConstraint:Float


	
	Method Update:Void()
			
	End Method
	
	'Summary:  Returns a Float[x,y,w,h] of the minimum bounding box covering all FocalPoints in a stack.
	Function MinBoundingBox:Float[] (s:Stack<FocalPoint>)
		Local out:Float[4]
		If s.IsEmpty() Then Return out
		
		Local p:= s.Get(0)
		out[0] = p.x
		out[1] = p.y
		out[2] = p.w
		out[3] = p.h
		
		For Local o:= EachIn s
			out[0] = Min(o.x, out[0])
			out[1] = Min(o.y, out[1])
			out[2] = Max(o.x + o.w, out[2])
			out[3] = Max(o.y + o.h, out[3])			
		Next
		
		Return out
	End Function
End Class