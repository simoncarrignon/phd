#include <mEDEA-sp/include/MedeaSpEnergyPoint.h>
#include "RoboroboMain/roborobo.h"
#include "Utilities/Misc.h"
#include "Utilities/SDL_gfxPrimitives.h"

#include "World/World.h"


void MedeaSpEnergyPoint::setQ_E(int __Q_E){_Q_E=__Q_E;}
int MedeaSpEnergyPoint::getQ_E(){return _Q_E;}


MedeaSpEnergyPoint::MedeaSpEnergyPoint(float __type){
	_type=__type;
}


void MedeaSpEnergyPoint::setType(float  __type){
	 _type = __type;
}


float MedeaSpEnergyPoint::getType(){
      return _type;
}

int MedeaSpEnergyPoint::getNHarvest(){
	return _nHarvest;
}
void MedeaSpEnergyPoint::setNHarverst(int nHarvest)
{
	_nHarvest = nHarvest;
}


void MedeaSpEnergyPoint::display()
{
	
	Uint32 red =0xFFDBC1ff;//FFB985ff;//ff7f2aff;//FFB985
	Uint32 blue =0xD6EEF4ff;// 87cddeff;
	Uint32 color;
	//
	if(_type == 0)color = blue;// SDL_MapRGB(gBackgroundImage->format, 0xa0, 0xef, 0x40);
	if(_type == 1)color = red ;// SDL_MapRGB(gBackgroundImage->format, 0xa0, 0x00, 0xee);
	
	for (Sint16 xColor = _xCenterPixel - Sint16(_radius) ; xColor < _xCenterPixel + Sint16(_radius) ; xColor++)
	{
		for (Sint16 yColor = _yCenterPixel - Sint16(_radius) ; yColor < _yCenterPixel + Sint16 (_radius); yColor ++)
		{
			if ((sqrt ( pow (xColor-_xCenterPixel,2) + pow (yColor - _yCenterPixel,2))) < _radius)
			{
				pixelColor(gBackgroundImage, xColor, yColor, color);
			}
		}
	}
	
}
