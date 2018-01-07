// ====================================================================
//  SouthEnd Multi column listbox with image support
// ====================================================================



class GUIMultiList extends GUIList;

#exec OBJ LOAD FILE=GUIContent.utx

var int numberOfColumns;
var float columnOffset[10]; // GUIMultiListBoxLine
var int columnAlignment[10]; // GUIMultiListBoxLine




function bool SetColumnAlignment(int colIdx, int align) // 0 == left 1 == center 2 == right
{
  if (numberOfColumns <= colIdx)
    return false;
  columnAlignment[colIdx] = align;
  return true;
}

function bool SetNumberOfColumns(int nrCols)
{
  if (nrCols > 10 || nrCols < 0)
  {
    numberOfColumns = 0;
    return false;
  }

  numberOfColumns = nrCols;
  return true;
}

function bool SetColumnOffset(int colIdx, int xOffs)
{
  if (numberOfColumns <= colIdx)
    return false;
  columnOffset[colIdx] = xOffs;
  return true;
}

//function bool InternalOnPreDrawItem(Canvas canvas)
//{
//  UserDefinedItemHeight = 55;
//  //canvas.Font = font'XIIIFonts.PoliceF20';
//  return true;

//}

function InternalOnDrawItem(Canvas Canvas, int Item, float X, float Y, float W, float H, bool bSelected)
{
  local int q;
  local GUIMultiListBoxLine line;
  local texture tex;
  local texture tt;
  local float dW, dH, dY;
  local float availableWidth;
  local float alignX;

  if (bSelected)
  {
    canvas.DrawColor.R = 255;
    canvas.DrawColor.G = 255;
    canvas.DrawColor.B = 255;
    canvas.DrawColor.A = 255;

    //tt = texture'GUIContent.Menu.MN_cadre01';//MN_cadre01';  //MN_glowvalid
    canvas.SetPos(X, Y);
    Canvas.DrawTileStretched(tt, W, H);

    canvas.DrawColor.R = 0;
    canvas.DrawColor.G = 0;
    canvas.DrawColor.B = 0;
  }
  else
  {
    canvas.DrawColor.R = 0;
    canvas.DrawColor.G = 0;
    canvas.DrawColor.B = 0;
  }
  canvas.DrawColor.A = 255;


  canvas.TextSize(Elements[item].Item, dW, dH);
  if (numberOfColumns == 1)
    availableWidth = W-20;
  else
    availableWidth = columnOffset[1]-10;
  dY = 0;
  if (dW > availableWidth)
  {
    //canvas.Font = font'XIIIFonts.XIIISmallFont';

    alignX = 2;
    canvas.TextSize(Elements[item].Item, dW, dH);
    if (columnAlignment[0] == 1)
    {
      alignX = (availableWidth - dW)*0.5;
    }
    else if (columnAlignment[0] == 2)
    {
      alignX = (availableWidth - dW);
    }

    dY = 5;
  }
  else
  {
    if (columnAlignment[0] == 0)
      alignX = 0;
    else if (columnAlignment[0] == 1)
      alignX = (availableWidth - dW)*0.5;
    else
      alignX = (availableWidth - dW) - 2;

    //canvas.Font = font'XIIIFonts.PoliceF16';
  }


  canvas.SetPos(alignX+X+columnOffset[0]+10, Y+dY+(H-16.0)*0.5-2);
  canvas.DrawText(Elements[item].Item, false);

  //canvas.Font = font'XIIIFonts.PoliceF16';

  line = GUIMultiListBoxLine(Elements[item].ExtraData);
  for (q=0; q<numberOfColumns-1; q++)
  {
    dY = 0;

    if (line.items[q].tex == none)
    {

      if (numberOfColumns-2 == q)
      {
        availableWidth = W - 10 - columnOffset[q+1];
      }
      else
        availableWidth = columnOffset[q+2]-columnOffset[q+1];
      canvas.TextSize(line.items[q].str, dW, dH);


      if (dW > availableWidth)
      {
        //canvas.Font = font'XIIIFonts.XIIISmallFont';

        alignX = 2;
        canvas.TextSize(line.items[q].str, dW, dH);
        if (columnAlignment[q+1] == 1)
        {
          alignX = (availableWidth - dW)*0.5;
        }
        else if (columnAlignment[q+1] == 2)
        {
          alignX = (availableWidth - dW);
        }
        dY = 5;
      }
      else
      {
        //canvas.Font = font'XIIIFonts.PoliceF16';

        if (columnAlignment[q+1] == 0)
          alignX = 2;
        else if (columnAlignment[q+1] == 1)
          alignX = (availableWidth - dW)*0.5;
        else
          alignX = (availableWidth - dW) - 2;
      }

      canvas.SetPos(alignX+X+columnOffset[q+1], Y+dY+(H-16.0)*0.5-2);
      canvas.DrawColor.R = 0;
      canvas.DrawColor.G = 0;
      canvas.DrawColor.B = 0;
      canvas.DrawText(line.items[q].str, false);
      //canvas.Font = font'XIIIFonts.PoliceF16';
    }
    else
    {
      tex = line.items[q].tex;

      canvas.SetPos(X+columnOffset[q+1], Y+ (H - tex.VSize)*0.5 );
      if (bSelected)
      {
        canvas.DrawColor.R = 255;
        canvas.DrawColor.G = 255;
        canvas.DrawColor.B = 255;
      }
      else
      {
        canvas.DrawColor.R = 225;
        canvas.DrawColor.G = 225;
        canvas.DrawColor.B = 225;
      }
      Canvas.SetDrawColor( 255,255,255,255  );

      canvas.Style = 5;  // ERenderStyle.STY_Alpha;     Defined in XIIIMPBotInteraction !!!!  HUUUUUUH!!!!!!!!!
      canvas.DrawTile(tex, tex.USize, tex.VSize, 0, 0, tex.USize, tex.VSize);
      canvas.Style = 1;// ERenderStyle.STY_Normal;
    }
  }

  //
}


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  Super.Initcomponent(MyController, MyOwner);
  OnDrawItem=InternalOnDrawItem;
//  OnPreDraw=InternalOnPreDrawItem;
}






defaultproperties
{
     numberOfColumns=1
}
