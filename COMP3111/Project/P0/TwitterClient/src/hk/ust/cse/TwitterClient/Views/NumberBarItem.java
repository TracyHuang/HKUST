package hk.ust.cse.TwitterClient.Views;

import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.HoverClickableComposite;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import java.text.DecimalFormat;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class NumberBarItem extends HoverClickableComposite {
  
  public NumberBarItem(Composite parentView, long number, String title, int width, int height, 
      Color origColor, Color hoverColor, Color clickedColor, Font numberFont, Font titleFont) {
    super(parentView, origColor, hoverColor, clickedColor);

    m_number = number;
    m_title  = title;
    
    initialize(width, height, numberFont, titleFont);
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        Rectangle rect = NumberBarItem.this.getClientArea();
        if (!rect.contains(arg0.x, arg0.y)) {
          m_titleLabel.setForeground(Resources.GRAY_COLOR);
          m_numberLabel.setForeground(Resources.TEXT_COLOR);
        }
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        m_titleLabel.setForeground(Resources.LINK_COLOR);
        m_numberLabel.setForeground(Resources.LINK_COLOR);
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        NumberBarItem.this.widgetDisposed(e);
      }
    });
  }

  private void initialize(int width, int height, Font numberFont, Font titleFont) {
    // set size
    setSize(width, height);
    
    // set layout of the view
    RowLayout layout = new RowLayout(SWT.HORIZONTAL);
    layout.center       = true;
    layout.marginTop    = 0;
    layout.marginBottom = 0;
    layout.marginLeft   = 15;
    layout.marginRight  = 15;
    layout.spacing      = 0;
    setLayout(layout);
    
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds

    // necessary to place content in the middle
    Composite alignMiddle = new Composite(this, 0);
    alignMiddle.setLayoutData(new RowData(0, height));
    
    // set the content frame
    RowComposite content = new RowComposite(this, 0, SWT.VERTICAL, false, 0, 0, 0, 0, 2);
    content.setLayoutData(new RowData(getBounds().width - layout.marginLeft - layout.marginRight, -1));
    
    // set number
    m_numberLabel = new Label(content, SWT.LEFT);
    m_numberLabel.setFont(numberFont);
    m_numberLabel.setForeground(Resources.TEXT_COLOR);
    m_numberLabel.setText(new DecimalFormat("#,###").format(m_number));
    
    // set title
    m_titleLabel = new Label(content, SWT.LEFT);
    m_titleLabel.setFont(titleFont);
    m_titleLabel.setForeground(Resources.GRAY_COLOR);
    m_titleLabel.setText(m_title);

    layout(); // trigger re-layout
    pack(); // force re-size
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public long getNumber() {
    return m_number;
  }
  
  public String getTitle() {
    return m_title;
  }

  private final long   m_number;
  private final String m_title;

  private Label m_numberLabel;
  private Label m_titleLabel;
}
