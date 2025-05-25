# Nice

*Docs:*

body {
    background: #333;
    color: #333;
    -webkit-filter: invert(100%);
    filter: invert(100%) ;
}

body::-webkit-scrollbar {
  width: 12px;               /* width of the entire scrollbar */
}

body::-webkit-scrollbar-track {
  background: #333;        /* color of the tracking area */
}

body::-webkit-scrollbar-thumb {
  background-color: #666;    /* color of the scroll thumb */
  border-radius: 20px;       /* roundness of the scroll thumb */
  border: 3px solid #333;  /* creates padding around scroll thumb */
}
Excellent… appended this to:

Platform.userAppSupportDir ++ "/Help/scdoc.css"
