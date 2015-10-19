package hk.ust.cse.TwitterClient.Views;

import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.ClickableComposite;
import hk.ust.cse.TwitterClient.Views.Basic.ClickableImageLabel;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class ListView extends RowComposite {
  
  public ListView(Composite parentView, int width) {
    super(parentView, SWT.CENTER, SWT.VERTICAL, false, 0, 0, 0, 0, 1);

    m_items = new ArrayList<Composite>();
    
    initialize(null, width);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ListView.this.widgetDisposed(e);
      }
    });
  }
  
  public ListView(Composite parentView, String headerText, int width, 
      String backHandler, Object backHandlerCallee, String nextHandler, Object nextHandlerCallee) {
    super(parentView, SWT.CENTER, SWT.VERTICAL, false, 0, 0, 0, 0, 1);

    m_items = new ArrayList<Composite>();
    
    m_backHandler       = backHandler;
    m_backHandlerCallee = backHandlerCallee;
    m_nextHandler       = nextHandler;
    m_nextHandlerCallee = nextHandlerCallee;
    
    initialize(headerText, width);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ListView.this.widgetDisposed(e);
      }
    });
  }

  private void initialize(String headerText, int width) {
    // set size
    setSize(width, -1);
    
    // set background color
    setBackground(Resources.SPLIT_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set header label
    if (headerText != null) {
      // set the name frame
      RowComposite headerFrame = new RowComposite(this, 0, SWT.HORIZONTAL, true, 0, 0, 10, 10, -1);
      headerFrame.setLayoutData(new RowData(getBounds().width, 44));
      headerFrame.setBackground(Resources.WHITE_COLOR);
      headerFrame.setAlignMiddle(44);

      m_header = new Label(headerFrame, 0);
      m_header.setFont(Resources.FONT14B);
      m_header.setForeground(Resources.TEXT_COLOR);
      m_header.setText(headerText);
      m_header.setLayoutData(new RowData(getBounds().width - 60, -1));
      
      RowComposite rightHeaderFrame = new RowComposite(headerFrame, 0, SWT.HORIZONTAL, false, 0, 0, 0, 0, 5);
      rightHeaderFrame.setLayoutData(new RowData(30, 13));
      
      ClickableComposite backButtonView = new ClickableComposite(rightHeaderFrame);
      backButtonView.setLayout(new FillLayout());
      backButtonView.setLayoutData(new RowData(Resources.BACK_IMG.getBounds().width, 
                                               Resources.BACK_IMG.getBounds().height));
      new ClickableImageLabel(backButtonView, 0, Resources.BACK_IMG, 
          Resources.BACK_CLICKED_IMG, m_backHandler, m_backHandlerCallee);
      
      ClickableComposite nextButtonView = new ClickableComposite(rightHeaderFrame);
      nextButtonView.setLayout(new FillLayout());
      nextButtonView.setLayoutData(new RowData(Resources.GO_IMG.getBounds().width, 
                                               Resources.GO_IMG.getBounds().height));
      new ClickableImageLabel(nextButtonView, 0, 
          Resources.GO_IMG, Resources.GO_CLICKED_IMG, m_nextHandler, m_nextHandlerCallee);
    }
    
    layout();
    pack();
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public void addItem(Composite item) {
    addItems(Arrays.asList(new Composite[] {item}));
  }
  
  public void addItems(List<? extends Composite> items) {
    m_items.addAll(items);
    for (Composite item : items) {
      item.setParent(this);
    }

    layout(); // trigger re-layout
    pack(); // force re-size of height, the width should not be changed
  }

  private Label  m_header;
  private String m_backHandler;
  private String m_nextHandler;
  private Object m_backHandlerCallee;
  private Object m_nextHandlerCallee;
  
  private final List<Composite> m_items;
}
