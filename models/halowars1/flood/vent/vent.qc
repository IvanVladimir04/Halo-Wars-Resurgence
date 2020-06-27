// Created by Crowbar 0.68

$modelname "halowars1/flood/vent.mdl"

$surfaceprop "flesh"

$cdmaterials "\models\halowars\floodvent\"

$scale 0.7

$BodyGroup "Base"
{
	studio "base.smd"
}
$BodyGroup "Infested"
{
	studio "infested.smd"
}

$sequence "Idle1" {
	"ventanims\idle1.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Idle2" {
	"ventanims\idle2.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Idle3" {
	"ventanims\idle3.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Growth1" {
	"ventanims\growth1.smd"
	activity "ACT_GET_UP_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Growth2" {
	"ventanims\growth2.smd"
	activity "ACT_GET_UP_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Growth3" {
	"ventanims\growth3.smd"
	activity "ACT_GET_UP_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Shrink1" {
	"ventanims\shrink1.smd"
	activity "ACT_GET_DOWN_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Shrink2" {
	"ventanims\shrink2.smd"
	activity "ACT_GET_DOWN_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Shrink3" {
	"ventanims\shrink3.smd"
	activity "ACT_GET_DOWN_STAND" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}