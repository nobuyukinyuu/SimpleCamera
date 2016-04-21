Import mojo
Import focalpoint

Class Camera
  Private
	Field __filterX:Float, __filterY:Float  'Debug display for filtering amount currently being applied.
	Field original_matrix:Float[]           'Cache for the global matrix used before we applied Focus()
  Public
  	Field viewPortW:Int = DeviceWidth(), viewPortH:Int = DeviceHeight()
	Field x:Float, y:Float   'The filtered x/y position of this camera.
	Field focalPoints:= New Stack<FocalPoint>
	
	Field xRoam:Float, yRoam:Float  'Percentage of screen space "slack" allowed before the camera starts to pan.
	Field xRoamPad:Float, yRoamPad:Float  'Amount of padding added to filter the camera's pan response.
	Field xConstraintMin:Float = $80000000, yConstraintMin:Float = $80000000
	Field xConstraintMax:Float = $7FFFFFFF, yConstraintMax:Float = $7FFFFFFF
	
	Field zConstraint:Float

	Field filterX:Float, filterY:Float  'Amount to filter the camera's position by default.  From [0-1).
	Field filterSnap:Float = 0.002  'How close the filtering should be to 1 before filtering is disabled.
	
	'TODO:  Delta timed position filtering
	Field timeBase:= New FloatObject(1.0)   'Delta time reference.  Replace this with your own delta time reference!
	
	Method New(viewport_width:Int, viewport_height:Int)
		viewPortW = viewport_width; viewPortH = viewport_height
	End Method
	
	Method Update:Void()
			If focalPoints.IsEmpty Then Return
	
			Local panw:Float = xRoam * viewPortW * 0.5  'Roam distance, in px
			Local panh:Float = yRoam * viewPortH * 0.5
			Local padw:Float = xRoamPad * viewPortW * 0.5  'Pad distance, in px
			Local padh:Float = yRoamPad * viewPortH * 0.5
					
			If focalPoints.Length = 1
				Local o:FocalPoint = focalPoints.Get(0)
								
				'Check to see if our focal point is outside of the roaming range.
				'Determine the filtering amount based on the distance from the pad border.
				'Filtering should range between 1 (no padding at all) to filterX.
				Local dist:Float = o.FocalX() -x
				Local sign:Int = Sgn(dist)
				Local filterAmt:Float = 1
				
				If Abs(dist) > panw And padw > 0
					'Based on the direction the camera needs to travel, we need to take the roam length out of our distance value.
					dist -= (panw * sign)
					'Now, we lerp the filtering amount between 1 and filterX.
					filterAmt = Lerp(1, filterX, Clamp(Abs(dist / padw), 0.0, 1.0))
					filterAmt = Snap(filterAmt)
	
					x = Clamp(Xerp(o.FocalX + dist - (panw * sign), x, filterAmt), xConstraintMin + viewPortW / 2, xConstraintMax - viewPortW / 2)
				ElseIf padw = 0  'No padding.
					If Abs(dist) > panw Then filterAmt = filterX Else filterAmt = 1
					x = Clamp(Lerp(x + dist - (panw * sign), x, filterAmt), xConstraintMin + viewPortW / 2, xConstraintMax - viewPortW / 2)
				End If
				
				__filterX = filterAmt
				
				'Do the same thing for the Y-Axis.
				 dist = o.FocalY() -y
				 sign = Sgn(dist)
				 filterAmt = 1
					
				If Abs(dist) > panh And padh > 0
					dist -= (panh * sign)
					filterAmt = Lerp(1, filterY, Clamp(Abs(dist / padh), 0.0, 1.0))
					filterAmt = Snap(filterAmt)

					y = Clamp(Xerp(o.FocalY + dist - (panh * sign), y, filterAmt), yConstraintMin + viewPortH / 2, yConstraintMax - viewPortH / 2)
				ElseIf padh = 0  'No padding.
					If Abs(dist) >= panh Then filterAmt = filterY Else filterAmt = 1
					y = Clamp(Lerp(y + dist - (panh * sign), y, filterAmt), yConstraintMin + viewPortH / 2, yConstraintMax - viewPortH / 2)
				End If
				
				__filterY = filterAmt

			Else   'Multiple focal points.  Find center of bounding box.
			
			End If
	End Method
	
	'Summary:  Changes the global matrix to focus on this camera's FocalPoints.
	Method Focus:Void()
		original_matrix = GetMatrix()

		''TODO:  Implement zoom
		'Transform(1, 0, 0, 1, -x + viewPortW / 2, -y + viewPortH / 2)
		Translate(-x + viewPortW / 2, -y + viewPortH / 2)
	End Method
	Method UnFocus:Void()
		SetMatrix(original_matrix)
	End Method
	
	'Summary:  Debug way to see where the roam constraints are.
	Method RenderDebug:Void()
		Local w:Float = xRoam * viewPortW * 0.5
		Local h:Float = yRoam * viewPortH * 0.5
		Local w2:Float = (xRoam + xRoamPad) * viewPortW * 0.5  'Pad
		Local h2:Float = (yRoam + yRoamPad) * viewPortH * 0.5
		Local cx:Float = viewPortW / 2
		Local cy:Float = viewPortH / 2
		
			SetAlpha(0.5); SetColor(0, 255, 255)
			DrawLine(cx - w, 0, cx - w, viewPortH)
			DrawLine(cx + w, 0, cx + w, viewPortH)
			DrawLine(0, cy - h, viewPortW, cy - h)
			DrawLine(0, cy + h, viewPortW, cy + h)
			
			SetColor(0, 255, 0)
			DrawLine(cx - w2, cy - h2, cx - w2, cy + h2)
			DrawLine(cx + w2, cy - h2, cx + w2, cy + h2)
			DrawLine(cx - w2, cy - h2, cx + w2, cy - h2)
			DrawLine(cx - w2, cy + h2, cx + w2, cy + h2)
			
			SetAlpha(1); SetColor(255, 255, 255)
			
			DrawText(x + "," + y, 8, 8)
			DrawText(__filterX + "," + __filterY, 8, 24)
	End Method
	
	
	'Summary:  Sets the filtering amount.  Set expScale to FALSE to disable exponential scaling
	Method SetFilter:Void(amt:Float, expScale:Bool = True)
		If expScale Then amt = -Pow( (Clamp(amt, 0.0, 1.0) + 1), -7) + 1
		filterX = amt; filterY = amt
	End Method
	Method SetFilter:Void(amtX:Float, amtY:Float, expScale:Bool = True)
		If expScale Then
			amtX = -Pow( (Clamp(amtX, 0.0, 1.0) + 1), -7) + 1
			amtY = -Pow( (Clamp(amtY, 0.0, 1.0) + 1), -7) + 1
		End If
		filterX = amtX; filterY = amtY
	End Method
	
	'Summary:  Sets the position of the camera, respecting the constraints.
	Method SetPos:Void(x:Float, y:Float)
		Self.x = Clamp(x, xConstraintMin + viewPortW / 2, xConstraintMax - viewPortW / 2)
		Self.y = Clamp(y, yConstraintMin + viewPortH / 2, yConstraintMax - viewPortH / 2)
	End Method
	
	'Summary:  Snaps an amount based on filterSnap to 1.0 (no movement) if within range of the roam boundry.
	Method Snap:Float(amt:Float)
		If filterSnap + amt >= 1.0 Then Return 1.0 Else Return amt
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

	'Summary:  Distance squared.  Faster than performing a distance calc for comparing lengths.
	Function DistSq(x:Float, y:Float, x2:Float, y2:Float)
		 Return (x2 - x) * (x2 - x) + (y2 - y) * (y2 - y)
	End Function
		
	'Summary:  Linearly interpolates from x to y.
	Function Lerp:Float(x:Float, y:Float, amt:Float = 0.5)
		Return x + amt * (y - x)
	End Function
	
	'Summary:  Performs a Lerp after exponentially weighting the amount.
	Function Xerp:Float(x:Float, y:Float, amt:Float)
		amt = Clamp(-Pow( (Clamp(amt, 0.0, 1.0) + 1), -7) + 1, 0.0, 1.0)
		Return Lerp(x, y, amt)
	End Function
End Class