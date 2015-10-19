package hk.ust.cse.TwitterClient.Views;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;

public class NumberBar extends RowComposite {
  
  public NumberBar(Composite parentView, long[] numbers, String[] titles, int width, 
      int singleWidth, int height, Color origColor, Color hoverColor, Color clickedColor, 
      Font numberFont, Font titleFont, boolean horizontalBars, String numClkHandler, Object handlerCallee) {
    super(parentView, SWT.CENTER, SWT.HORIZONTAL, true, 0, 0, 0, 0, 0);

    m_numbers = numbers;
    m_titles  = titles;
    m_items   = new ArrayList<NumberBarItem>();

    m_numClkHandler = numClkHandler;
    m_handlerCallee = handlerCallee;
    
    initialize(width, singleWidth, height, origColor, hoverColor, clickedColor, numberFont, titleFont, horizontalBars);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        NumberBar.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize(int width, int singleWidth, int height, Color origColor, 
      Color hoverColor, Color clickedColor, Font numberFont, Font titleFont, boolean horizontalBars) {
    // set size
    setSize(width, height);
    
    // set background color
    setBackground(Resources.SPLIT_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    setAlignMiddle(height);
    
    int frameHeight = height - (horizontalBars ? 2 : 0);
    RowComposite numbersFrame = new RowComposite(this, 0, SWT.HORIZONTAL, false, 0, 0, 0, 0, 1);
    numbersFrame.setBackground(Resources.SPLIT_COLOR);
    numbersFrame.setLayoutData(new RowData(width, frameHeight));
    
    // set the number views
    int currentWidth = 0;
    for (int i = 0; i < m_numbers.length; i++) {
      int viewWidth = (i < m_numbers.length - 1) ? singleWidth : width - currentWidth;
      NumberBarItem item = new NumberBarItem(numbersFrame, m_numbers[i], m_titles[i], viewWidth, 
          frameHeight, origColor, hoverColor, clickedColor, numberFont, titleFont);
      if (m_numClkHandler != null) {
        Utils.addClickListener(item, m_numClkHandler, m_handlerCallee);
      }
      m_items.add(item);
      currentWidth += item.getBounds().width + 1;
    }
    
    layout(); // trigger re-layout
    pack(); // force re-size
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  private final long[]              m_numbers;
  private final String[]            m_titles;
  private final List<NumberBarItem> m_items;
  
  private final String m_numClkHandler;
  private final Object m_handlerCallee;
}
