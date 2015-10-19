package hk.ust.cse.TwitterClient.Views.Basic;

import hk.ust.cse.TwitterClient.Resources.Resources;

import java.lang.reflect.Method;

import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class ClickableImageLabel extends Label {

  public ClickableImageLabel(Composite parent, int style, final Image normalImage, 
      final Image hoverImage, final String clickHandler, final Object handlerCallee) {
    super(parent, style);
    
    setImage(normalImage);
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        setImage(normalImage);
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        setImage(hoverImage); 
        setCursor(Resources.HAND_CURSOR);
      }
    });
    
    if (clickHandler != null) {
      addMouseListener(new MouseListener() {
        @Override
        public void mouseUp(MouseEvent arg0) {
        }
        
        @Override
        public void mouseDown(MouseEvent arg0) {
          try {
            Method method = handlerCallee.getClass().getMethod(clickHandler, MouseEvent.class);
            method.invoke(handlerCallee, arg0);
          } catch (Exception e) {e.printStackTrace();}
        }
        
        @Override
        public void mouseDoubleClick(MouseEvent arg0) {
        }
      });
    }
  }

  protected void checkSubclass() {  
  }  
}
