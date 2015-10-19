package hk.ust.cse.TwitterClient.Views.Basic;

import hk.ust.cse.TwitterClient.Resources.Resources;

import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class LinkLabel extends Label {

  public LinkLabel(Composite parent, int style, final Color normalColor, 
      final Color hoverColor, final Font normalFont, final Font hoverFont) {
    super(parent, style);
    
    setForeground(normalColor);
    setFont(normalFont);
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        setForeground(normalColor);
        setFont(normalFont);
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) {
        setForeground(hoverColor);
        setFont(hoverFont); 
        setCursor(Resources.HAND_CURSOR);
      }
    });
  }

  protected void checkSubclass() {  
  }  
}
