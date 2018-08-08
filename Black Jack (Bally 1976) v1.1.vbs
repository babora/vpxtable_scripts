' Black Jack Bally 1976
' Allknowing2012
' April 2016

'1.00 - Original Release
'1.1 - Hauntfreaks image tweaks, mid-right rollover correction, sound fixes for rubbers/posts/pins, apron resized

'
' Thanks to prior VP authors for lamp and solenoid info
'

' Thalamus 2018-07-19
' Added/Updated "Positional Sound Playback Functions" and "Supporting Ball & Sound Functions"
' Changed UseSolenoids=1 to 2
' No special SSF tweaks yet.
' Wob 2018-08-08
' Added vpmInit Me to table init and both cSingleLFlip and cSingleRFlip

Option Explicit
Randomize

If Table1.ShowDT = False then ' hide the backglass lights when in FS mode
  B1.visible=False
  B2.visible=False
  B3.visible=False
  B4.visible=False
End If

Const cGameName="blackjck"   ' rom blackjcb for freeplay
Const UseSolenoids=2,UseLamps=True,UseGI=0,UseSync=1,SSolenoidOn="SolOn",SSolenoidOff="Soloff",SFlipperOn="FlipperUpLeft",SFlipperOff="FlipperDown"
' Wob: Added for Fast Flips (No upper Flippers)
Const cSingleLFlip = 0
Const cSingleRFlip = 0
Const SCoin="coin3",cCredits="Black Jack (Bally 1976)"
On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "Can't open controller.vbs"
On Error Goto 0

LoadVPM "01560000","Bally.vbs", 3.36
Dim DesktopMode: DesktopMode = Table1.ShowDT

SolCallback(2)="vpmSolSound SoundFX(""Chime10"",DOFChimes),"
SolCallback(3)="vpmSolSound SoundFX(""Chime100"",DOFChimes),"
SolCallback(4)="vpmSolSound SoundFX(""Chime1000"",DOFChimes),"
SolCallback(5)="vpmSolSound SoundFX(""ChimeExtra"",DOFChimes),"
SolCallback(6)="vpmSolSound SoundFX(""Knocker"",DOFKnocker),"
SolCallback(7)="SolBallRelease"
SolCallback(8)="bsSaucer.SolOut"

SolCallback(sLRFlipper) = "SolRFlipper"
SolCallback(sLLFlipper) = "SolLFlipper"

Dim dtL, dtR, bstrough, bsSaucer

Sub SolLFlipper(Enabled)
	If Enabled Then
			 PlaySound SoundFX("FlipperUpLeft",DOFContactors):LeftFlipper.RotateToEnd
		 Else
			 PlaySound SoundFX("FlipperDown",DOFContactors):LeftFlipper.RotateToStart
	End If
End Sub

Sub SolRFlipper(Enabled)
	If Enabled Then
			 PlaySound SoundFX("FlipperUpRight",DOFContactors):RightFlipper.RotateToEnd
	Else
			 PlaySound SoundFX("FlipperDown",DOFContactors):RightFlipper.RotateToStart
	End If
End Sub

Const sEnable=19
SolCallback(sEnable)="GameOn"

Sub GameOn(enabled)
  vpmNudge.SolGameOn(enabled)
 If Enabled Then
    GIOn
  Else
    GIOff
  End If
End Sub


Sub solballrelease(enabled)
    bstrough.solexit ssolenoidon, ssolenoidon,enabled:playsound SoundFX("BallRelease",DOFContactors)
End sub

Sub Table1_Init
	vpmInit Me
	On Error Resume Next
	With Controller
		.GameName=cGameName
		If Err Then MsgBox "Can't start Game" & cGameName & vbNewLine & Err.Description : Exit Sub
		.SplashInfoLine=cCredits
		.HandleMechanics=0
		.HandleKeyboard=0
		.ShowDMDOnly=1
		.ShowFrame=0
		.Hidden=True
		.ShowTitle=0
	End With
	Controller.Run
	If Err Then MsgBox Err.Description
	On Error Goto 0

	PinMAMETimer.Interval=PinMAMEInterval
	PinMAMETimer.Enabled=1
	vpmNudge.TiltSwitch=-7  'swTilt
	vpmNudge.Sensitivity=3
	vpmNudge.TiltObj=Array(LeftSlingshot,RightSlingshot,Bumper1,Bumper2,Bumper3,sw35a,sw35b)
	vpmNudge.SolGameOn(True)

    set bstrough= new cvpmballstack
    bstrough.initnotrough ballrelease,8,80,5

	Set bsSaucer=New cvpmBallStack
	bsSaucer.InitSaucer Kicker1,32,245+Int(Rnd*10),3
	bsSaucer.InitExitSnd SoundFX("popper_ball",DOFContactors),SoundFX("popper_ball",DOFContactors)

    vpmMapLights InsertLights
End Sub

Sub Table1_Exit
  If B2SOn then Controller.Stop
End Sub

Sub Table1_KeyDown(ByVal keycode)
	If KeyCode=PlungerKey Then Plunger.Pullback:PlaySound "PlungerPull"
	If vpmKeyDown(KeyCode) Then Exit Sub
End Sub

Sub Table1_KeyUp(ByVal keycode)
	If KeyCode=PlungerKey Then Plunger.Fire:PlaySound "Plunger"
    if keycode=82 then
      vpmTimer.pulsesw 32
    end if
	If vpmKeyUp(KeyCode) Then Exit Sub
End Sub

Sub SpinnerLeft_spin():PlaySound "fx_spinner":vpmtimer.pulsesw 5:end Sub

'Circle Targets
Sub sw25a_Hit:vpmTimer.PulseSw 25:DOF 102, DOFPulse:End Sub
Sub sw25b_Hit:vpmTimer.PulseSw 25:DOF 101, DOFPulse:End Sub
Sub sw26a_Hit:vpmTimer.PulseSw 26:DOF 101, DOFPulse:End Sub
Sub sw26b_Hit:vpmTimer.PulseSw 26:DOF 101, DOFPulse:End Sub


' Rubber Walls
Sub sw35a_Hit
  vpmTimer.PulseSw 35
  SideRubber0A.visible=False
  SideRubber1A.visible=True
  sw35a.timerinterval=100
  sw35a.timerenabled=True
End Sub

Sub sw35a_timer()
  SideRubber0A.visible=True
  SideRubber1A.visible=False
  sw35a.timerenabled=False
End Sub


Sub sw35b_Hit
  vpmTimer.PulseSw 35
  SideRubber0.visible=False
  SideRubber1.visible=True
  sw35b.timerinterval=100
  sw35b.timerenabled=True
End Sub

Sub sw35b_timer()
  SideRubber0.visible=True
  SideRubber1.visible=False
  sw35b.timerenabled=False
End Sub


' Rollover Switches
Sub sw27_Hit:Controller.Switch(27)=1:End Sub
Sub sw27_unHit:Controller.Switch(27)=0:End Sub
Sub sw28_Hit:Controller.Switch(28)=1:End Sub
Sub sw28_unHit:Controller.Switch(28)=0:End Sub
Sub sw29_Hit:Controller.Switch(29)=1:End Sub
Sub sw29_unHit:Controller.Switch(29)=0:End Sub
Sub sw30_Hit:Controller.Switch(30)=1:End Sub
Sub sw30_unHit:Controller.Switch(30)=0:End Sub

Sub sw34_Hit:Controller.Switch(34)=1:End Sub
Sub sw34_unHit:Controller.Switch(34)=0:End Sub
Sub sw33_Hit:Controller.Switch(33)=1:End Sub
Sub sw33_unHit:Controller.Switch(33)=0:End Sub

Sub sw31a_Hit:Controller.Switch(31)=1:DOF 103, DOFOn:End Sub
Sub sw31a_unHit:Controller.Switch(31)=0:DOF 103, DOFOff:End Sub
Sub sw31b_Hit:Controller.Switch(31)=1:DOF 104, DOFOn:End Sub
Sub sw31b_unHit:Controller.Switch(31)=0:DOF 104, DOFOff:End Sub

Sub sw4_Hit:Controller.Switch(4)=1:End Sub
Sub sw4_unHit:Controller.Switch(4)=0:End Sub

Sub sw23_Hit:Controller.Switch(23)=1:End Sub
Sub sw23_unHit:Controller.Switch(23)=0:End Sub
Sub sw31_Hit:Controller.Switch(31)=1:End Sub
Sub sw31_unHit:Controller.Switch(31)=0:End Sub
Sub Drain_Hit():bsTrough.AddBall Me::End Sub

Sub Kicker1_hit():bsSaucer.AddBall 0:End Sub

Sub GIOn
	dim bulb
	for each bulb in GILights
	bulb.state = LightStateOn
	next
End Sub

Sub GIOff
	dim bulb
	for each bulb in GILights
	bulb.state = LightStateOff
	next
End Sub

Set LampCallback=GetRef("UpdateMultipleLamps")

Sub UpdateMultipleLamps
  ' If kicker lit for ExtraBall or Special then you must have 5X
  if I12.State=LightStateOn or I28.State=LightStateOn Then
    Light5x.state=LightStateOn
  Else
    Light5x.state=LightStateOff
  end if
End Sub

Sub FlipperTimer_Timer()
   GateLP.RotZ = ABS(GateL.currentangle)
   GateRP.RotZ = ABS(GateR.currentangle)
End Sub

Dim bump1,bump2,bump3

Sub Bumper1_Hit:vpmTimer.PulseSw 38:bump1 = 1:Me.TimerEnabled = 1:End Sub
Sub Bumper1_Timer()
	Select Case bump1
        Case 1:Ring1.Z = -30:bump1 = 2
        Case 2:Ring1.Z = -20:bump1 = 3
        Case 3:Ring1.Z = -10:bump1 = 4
        Case 4:Ring1.Z = 0:Me.TimerEnabled = 0
	End Select
End Sub

Sub Bumper2_Hit:vpmTimer.PulseSw 40:bump2 = 1:Me.TimerEnabled = 1:End Sub
Sub Bumper2_Timer()
	Select Case bump2
        Case 1:Ring2.Z = -30:bump2 = 2
        Case 2:Ring2.Z = -20:bump2 = 3
        Case 3:Ring2.Z = -10:bump2 = 4
        Case 4:Ring2.Z = 0:Me.TimerEnabled = 0
	End Select
End Sub

Sub Bumper3_Hit:vpmTimer.PulseSw 39:bump3 = 1:Me.TimerEnabled = 1:End Sub
Sub Bumper3_Timer()
	Select Case bump3
        Case 1:Ring3.Z = -30:bump3 = 2
        Case 2:Ring3.Z = -20:bump3 = 3
        Case 3:Ring3.Z = -10:bump3 = 4
        Case 4:Ring3.Z = 0:Me.TimerEnabled = 0
	End Select
End Sub


'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep, Tstep

Sub RightSlingShot_Slingshot
    PlaySound SoundFX("slingshotright",DOFContactors), 0, 1, 0.05, 0.05
    vpmTimer.PulseSw 36
    RSling.Visible = 0
    RSling1.Visible = 1
    sling1.TransZ = -20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.TransZ = -10
        Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.TransZ = 0:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub

Sub LeftSlingShot_Slingshot
    PlaySound SoundFX("slingshotleft",DOFContactors), 0, 1, 0.05, 0.05
    vpmTimer.PulseSw 37
    LSling.Visible = 0
    LSling1.Visible = 1
    sling2.TransZ = -20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.TransZ = -10
        Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.TransZ = 0:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub


'Digital LED Display

Dim Digits(28)
Digits(0)=Array(a00,a01,a02,a03,a04,a05,a06,n,a08)
Digits(1)=Array(a10,a11,a12,a13,a14,a15,a16,n,a18)
Digits(2)=Array(a20,a21,a22,a23,a24,a25,a26,n,a28)
Digits(3)=Array(a30,a31,a32,a33,a34,a35,a36,n,a38)
Digits(4)=Array(a40,a41,a42,a43,a44,a45,a46,n,a48)
Digits(5)=Array(a50,a51,a52,a53,a54,a55,a56,n,a58)
Digits(6)=Array(b00,b01,b02,b03,b04,b05,b06,n,b08)
Digits(7)=Array(b10,b11,b12,b13,b14,b15,b16,n,b18)
Digits(8)=Array(b20,b21,b22,b23,b24,b25,b26,n,b28)
Digits(9)=Array(b30,b31,b32,b33,b34,b35,b36,n,b38)
Digits(10)=Array(b40,b41,b42,b43,b44,b45,b46,n,b48)
Digits(11)=Array(b50,b51,b52,b53,b54,b55,b56,n,b58)
Digits(12)=Array(c00,c01,c02,c03,c04,c05,c06,n,c08)
Digits(13)=Array(c10,c11,c12,c13,c14,c15,c16,n,c18)
Digits(14)=Array(c20,c21,c22,c23,c24,c25,c26,n,c28)
Digits(15)=Array(c30,c31,c32,c33,c34,c35,c36,n,c38)
Digits(16)=Array(c40,c41,c42,c43,c44,c45,c46,n,c48)
Digits(17)=Array(c50,c51,c52,c53,c54,c55,c56,n,c58)
Digits(18)=Array(d00,d01,d02,d03,d04,d05,d06,n,d08)
Digits(19)=Array(d10,d11,d12,d13,d14,d15,d16,n,d18)
Digits(20)=Array(d20,d21,d22,d23,d24,d25,d26,n,d28)
Digits(21)=Array(d30,d31,d32,d33,d34,d35,d36,n,d38)
Digits(22)=Array(d40,d41,d42,d43,d44,d45,d46,n,d48)
Digits(23)=Array(d50,d51,d52,d53,d54,d55,d56,n,d58)
Digits(24)=Array(f00,f01,f02,f03,f04,f05,f06,n,f08)
Digits(25)=Array(f10,f11,f12,f13,f14,f15,f16,n,f18)

Digits(26)=Array(e00,e01,e02,e03,e04,e05,e06,n,e08)
Digits(27)=Array(e10,e11,e12,e13,e14,e15,e16,n,e18)

Sub DisplayTimer_Timer
	Dim ChgLED,ii,num,chg,stat,obj
	ChgLed = Controller.ChangedLEDs(&Hffffffff, &Hffffffff)
If Not IsEmpty(ChgLED) Then
		If DesktopMode = True Then
		For ii = 0 To UBound(chgLED)
			num = chgLED(ii, 0) : chg = chgLED(ii, 1) : stat = chgLED(ii, 2)
			if (num < 28) then
				For Each obj In Digits(num)
					If chg And 1 Then obj.State = stat And 1
					chg = chg\2 : stat = stat\2
				Next
			else

			end if
		next
		end if
end if
End Sub


'Bally Black Jack
'added by Inkochnito
Sub editDips
	Dim vpmDips : Set vpmDips = New cvpmDips
	With vpmDips
		.AddForm 700,400,"Black Jack - DIP switches"
		.AddChk 7,10,180,Array("Match feature", &H00100000)'dip 21
		.AddChk 205,10,115,Array("Credits display", &H00080000)'dip 20
		.AddFrame 2,30,190,"Maximum credits",&H00070000,Array("10 credits",&H00010000,"15 credits", &H00020000,"25 credits", &H00040000,"40 credits", &H00070000)'dip 17&18&19
		.AddFrame 2,184,190,"High score feature",&H00006000,Array("No award",0,"Extra Ball",&H00004000,"Replay",&H00006000)'dip 14&15
		.AddFrame 2,248,190,"Melody option (Not Supported?)",&H00000080,Array("Tunes off",0,"Tunes on",&H00000080)'dip 8
		.AddFrame 205,30,190,"High score to date",&H00000060,Array("No award",0,"1 credit",&H00000020,"2 credits",&H00000040,"3 credits",&H00000060)'dip 6&7
		.AddFrame 205,106,190,"Balls per game",32768,Array("3 balls",0,"5 balls",32768)'dip 16
		.AddFrame 205,152,190,"Beating the dealer",&H80000000,Array("Player loses on ties",0,"Player wins on ties",&H80000000)'dip 32
		.AddFrame 205,198,190,"Card lane feature",&H20000000,Array("Spinner lite and 50000 reset",0,"Spinner lite and 50000 in memory",&H20000000)'dip 30
		.AddFrame 205,248,190,"Top lanes feature",&H40000000,Array ("Reset",0,"In memory",&H40000000)'dip 31
		.AddLabel 50,310,300,20,"After hitting OK, press F3 to reset game with new settings."
		.ViewDips
	End With
End Sub
Set vpmShowDips = GetRef("editDips")

' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************

Sub Pins_Hit (idx)
	PlaySound "pinhit_low", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub Targets_Hit (idx)
	PlaySound SoundFX("target",DOFContactors), 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub TargetBankWalls_Hit (idx)
	PlaySound "target", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub Metals_Thin_Hit (idx)
	PlaySound "metalhit_thin", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Metals_Medium_Hit (idx)
	PlaySound "metalhit_medium", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Metals2_Hit (idx)
	PlaySound "metalhit2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Gates_Hit (idx)
	PlaySound "gate4", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Rubbers_Hit(idx)
 '  debug.print "rubber"
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 20 then
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End if
	If finalspeed >= 6 AND finalspeed <= 20 then
 		RandomSoundRubber()
 	End If
End Sub

Sub Posts_Hit(idx)
  '  debug.print "Posts"
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 16 then
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
 		RandomSoundRubber()
 	End If
End Sub

Sub RandomSoundRubber()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "rubber_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 2 : PlaySound "rubber_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 3 : PlaySound "rubber_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End Select
End Sub

Sub Bumpers_Hit(idx)
	Select Case Int(Rnd*4)+1
		Case 1 : PlaySound SoundFx("fx_bumper2",DOFContactors), 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 2 : PlaySound SoundFx("fx_bumper2",DOFContactors), 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 3 : PlaySound SoundFx("fx_bumper3",DOFContactors), 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 4 : PlaySound SoundFx("fx_bumper4",DOFContactors), 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End Select
End Sub

Sub LeftFlipper_Collide(parm)
 	RandomSoundFlipper()
End Sub

Sub RightFlipper_Collide(parm)
 	RandomSoundFlipper()
End Sub

Sub RandomSoundFlipper()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "flip_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 2 : PlaySound "flip_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 3 : PlaySound "flip_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End Select
End Sub

' *******************************************************************************************************
' Positional Sound Playback Functions by DJRobX
' PlaySound sound, 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
' *******************************************************************************************************

' Play a sound, depending on the X,Y position of the table element (especially cool for surround speaker setups, otherwise stereo panning only)
' parameters (defaults): loopcount (1), volume (1), randompitch (0), pitch (0), useexisting (0), restart (1))
' Note that this will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position

Sub PlayXYSound(soundname, tableobj, loopcount, volume, randompitch, pitch, useexisting, restart)
  PlaySound soundname, loopcount, volume, AudioPan(tableobj), randompitch, pitch, useexisting, restart, AudioFade(tableobj)
End Sub

' Set position as table object (Use object or light but NOT wall) and Vol to 1

Sub PlaySoundAt(soundname, tableobj)
  PlaySound soundname, 1, 1, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed.

Sub PlaySoundAtBall(soundname)
  PlaySoundAt soundname, ActiveBall
End Sub

'Set position as table object and Vol manually.

Sub PlaySoundAtVol(sound, tableobj, Vol)
  PlaySound sound, 1, Vol, Pan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed, but Vol Multiplier may be used eg; PlaySoundAtBallVol "sound",3

Sub PlaySoundAtBallVol(sound, VolMult)
  PlaySound sound, 0, Vol(ActiveBall) * VolMult, Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
End Sub

'Set position as bumperX and Vol manually.

Sub PlaySoundAtBumperVol(sound, tableobj, Vol)
  PlaySound sound, 1, Vol, Pan(tableobj), 0,0,1, 1, AudioFade(tableobj)
End Sub

'*********************************************************************
'                     Supporting Ball & Sound Functions
'*********************************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
  Dim tmp
  tmp = tableobj.y * 2 / table1.height-1
  If tmp > 0 Then
    AudioFade = Csng(tmp ^10)
  Else
    AudioFade = Csng(-((- tmp) ^10) )
  End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
  Dim tmp
  tmp = tableobj.x * 2 / table1.width-1
  If tmp > 0 Then
    AudioPan = Csng(tmp ^10)
  Else
    AudioPan = Csng(-((- tmp) ^10) )
  End If
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table1.width-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10) )
    End If
End Function

Function AudioFade(ball) ' Can this be together with the above function ?
  Dim tmp
  tmp = ball.y * 2 / Table1.height-1
  If tmp > 0 Then
    AudioFade = Csng(tmp ^10)
  Else
    AudioFade = Csng(-((- tmp) ^10) )
  End If
End Function

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
  Vol = Csng(BallVel(ball) ^2 / 2000)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
  Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
  BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function


'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 1 ' total number of balls
ReDim rolling(tnob)
InitRolling

Sub InitRolling
    Dim i
    RollingTimer.interval=100
    RollingTimer.enabled=True
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingTimer_Timer()
    Dim BOT, b
    BOT = GetBalls

	' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
    Next

	' exit the sub if no balls on the table
    If UBound(BOT) = -1 Then Exit Sub

    ' play the rolling sound for each ball
    For b = 0 to UBound(BOT)
      If BallVel(BOT(b) ) > 1 Then
        rolling(b) = True
        if BOT(b).z < 30 Then ' Ball on playfield
          PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) ), Pan(BOT(b) ), 0, Pitch(BOT(b) ), 1, 0, AudioFade(BOT(b) )
        Else ' Ball on raised ramp
          PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) )*.5, Pan(BOT(b) ), 0, Pitch(BOT(b) )+50000, 1, 0, AudioFade(BOT(b) )
        End If
      Else
        If rolling(b) = True Then
          StopSound("fx_ballrolling" & b)
          rolling(b) = False
        End If
      End If
    Next
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
  If Table1.VersionMinor > 3 OR Table1.VersionMajor > 10 Then
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 200, Pan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
  Else
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 200, Pan(ball1), 0, Pitch(ball1), 0, 0
  End if
End Sub

