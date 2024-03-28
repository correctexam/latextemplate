%% Copyright Arnaud Blouin 2023
%% This file extends the standard class 'article' for
%% being used within the app correctexam.
%% CHANGELOG
%% v1.5.0
%% - fixed: not able to use vspace in answerExamContent
%% - fixed: the provided example using answerExamContent was not good
%% - feat: the PDF metadata now contains exercise ID
%% v1.4.0
%% - new: new command 'answerExamContent'
%% v1.3.0
%% - fixed: json metadata must use double quotes
%% - fixed: json metadata must contain the pages
%% - fixed: \booltrue or \boolfalse must be prefixed with \global
%% - fixed: incorrect size metadata for all boxes
%% v1.2.0
%% - fixed: ID cells enlarged
%% v1.1.0
%% - change: QCM are not more double inner qcmExam
%%           environments. See the example to adapt your code
%% - feat: add metadata related to: the answer zones
%%         of questions; student ids
%% - fixed: bad numbering QCMs
%% - fixed: bad dimensions of boxes on multi-column
%% - fixed: student if boxes color changed to lightgray
%% - fixed: do not compile when defining a first command with a label
%% - fixed: better alignment of student IDs in the header
\ProvidesClass{exam}
              [2023/30/09 v1.4.0
 correctexam LaTeX document class]
\RequirePackage{xkeyval}
\LoadClass{article}

\newif\if@headerWithID
\@headerWithIDfalse

\DeclareOptionX{withid}{\@headerWithIDtrue}
\ProcessOptionsX

\RequirePackage{zref-savepos}
\RequirePackage{xfp}
\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage{listings}
\RequirePackage{lastpage}
\RequirePackage{fancyhdr}
\RequirePackage{xcolor}
\RequirePackage{mathpazo}
\RequirePackage{qcm}
\RequirePackage{ifthen}
\RequirePackage{xstring}
\PassOptionsToPackage{inline}{enumitem}
\RequirePackage{enumitem}
\RequirePackage{amssymb}
\RequirePackage[most]{tcolorbox}
\RequirePackage{multido}
\RequirePackage{fltpoint}
\RequirePackage{cleveref}
\RequirePackage{adjustbox}
\RequirePackage{refcount}
% \RequirePackage{tikz}
\RequirePackage{titlesec}

\titlespacing*{\section} {0pt}{0ex}{0ex}

\linespread{1.05}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Document geometry

% showframe,
\geometry{bottom=0.5cm, top=-1cm, left=1.3cm, right=1.3cm, headheight=5cm, includefoot, includehead}

\pagestyle{fancyplain}

\newbool{firstColomnBoxDone}
\boolfalse{firstColomnBoxDone}

\newbool{firstIdBoxDone}
\boolfalse{firstIdBoxDone}


%%% Patch calc for settotalheight with vspace
\makeatletter
\begingroup
\toks0=\expandafter{\@settodim{#1}{#2}{#3}}
\edef\x{\endgroup
  \long\def\noexpand\@settodim##1##2##3{\the\toks0 }}\x
\makeatother
%%%

% Conversion pixel to pt
\newcommand\pxtopt{65536}
% Conversion point to cm
\newcommand\pttocm{28.4527}
% Conversion pixel to cm
\newcommand\pxtocm{\fpeval{\pxtopt*\pttocm}}

\newcommand{\rectangle}[3][0pt]{{%
\adjustbox{cfbox=lightgray}{%
\fboxsep=-\fboxrule\sbox0{}\wd0=#2\ht0=#3\dp0=#1\relax{\box0}}}}

% \newcommand{\rectangle}[3]{\tikz \draw[#3] (0,0) rectangle (#1,#2);}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% student ID header

\newlength{\heighOfIdBox}
\newlength{\widthOfIdBox}
\newlength{\mylentt}
% \newcommand{\boxStudentID}{\fcolorbox{lightgray}{white}{\fontsize{19}{21}\selectfont\strut~~~~}}
\newcommand{\boxStudentID}{\rectangle{0.7cm}{0.8cm}}
\newcommand{\nbBoxesHeaderLine}{19}

\newcommand{\nameheader}{%
%% Computing the dimensions of ID boxes
\settototalheight{\heighOfIdBox}{\boxStudentID}%
\setlength{\widthOfIdBox}{\widthof{\multido{}{\nbBoxesHeaderLine}{~\boxStudentID}}}%
\large%
{%
  \setlength{\tabcolsep}{0.2em}%
  \begin{tabular}{rl}
    \textbf{\small NOM :} & \zsavepos{lastnamebox}\multido{}{\nbBoxesHeaderLine}{~\boxStudentID}\\
    \textbf{\small PRÉNOM :} & \zsavepos{firstnamebox}\multido{}{\nbBoxesHeaderLine}{~\boxStudentID}\\
    \if@headerWithID \textbf{\small NUM ETD :} & \zsavepos{stdidbox}\multido{}{\nbBoxesHeaderLine}{~\boxStudentID} \else \\  \fi
  \end{tabular}
}%
\if@headerWithID%
  \ifbool{firstIdBoxDone}{}{%
    \pdfinfo{/correctexam-stdid %
    (%
    \{%
    "x": \fpeval{round(\zposx{stdidbox}/\pxtocm, 3)}, %
    "y": \fpeval{round((\the\paperheight/\pttocm-\zposy{stdidbox}/\pxtocm) + 0.025, 3)}, %
    "w": \fpeval{round(\widthOfIdBox/\pttocm + 0.35, 3)}, %
    "h": \fpeval{round(\heighOfIdBox/\pttocm + 0.1, 3)}, %
    "p": \thepage%
    \}%
    )}%
  }%
\else%
\\%
\fi%
\ifbool{firstIdBoxDone}{}{%
% \begin{tikzpicture}[overlay]%
% \draw[red] (\fpeval{round(\zposx{lastnamebox}/\pxtocm + \evensidemargin/\pttocm, 3)}cm, \fpeval{round(-\topmargin/\pttocm - (\the\paperheight/\pttocm-\zposy{lastnamebox}/\pxtocm) + (\heighOfIdBox/\pttocm)/2 - 0.025, 3)}cm) rectangle ++(\fpeval{round(\widthOfIdBox/\pttocm + 0.35, 3)}cm, \fpeval{round(\heighOfIdBox/\pttocm + 0.1, 3)}cm);
% \end{tikzpicture}%
% \begin{tikzpicture}[overlay]%
%   \draw[red] (\fpeval{round(\zposx{firstnamebox}/\pxtocm + \evensidemargin/\pttocm, 3)}cm, \fpeval{round(-\topmargin/\pttocm - (\the\paperheight/\pttocm-\zposy{firstnamebox}/\pxtocm) + (\heighOfIdBox/\pttocm)/2 - 0.025, 3)}cm) rectangle ++(\fpeval{round(\widthOfIdBox/\pttocm + 0.35, 3)}cm, \fpeval{round(\heighOfIdBox/\pttocm + 0.1, 3)}cm);
% \end{tikzpicture}%
  \pdfinfo{/correctexam-lastname %
  (%
  \{ %
  "x": \fpeval{round(\zposx{lastnamebox}/\pxtocm, 3)}, %
  "y": \fpeval{round((\the\paperheight/\pttocm-\zposy{lastnamebox}/\pxtocm) + 0.025, 3)}, %
  "w": \fpeval{round(\widthOfIdBox/\pttocm + 0.35, 3)}, %
  "h": \fpeval{round(\heighOfIdBox/\pttocm + 0.1, 3)}, %
  "p": \thepage%
  \}%
  )}%
  \pdfinfo{/correctexam-firstname %
  (%
  \{ %
  "x": \fpeval{round(\zposx{firstnamebox}/\pxtocm, 3)}, %
  "y": \fpeval{round((\the\paperheight/\pttocm-\zposy{firstnamebox}/\pxtocm) + 0.025, 3)}, %
  "w": \fpeval{round(\widthOfIdBox/\pttocm + 0.35, 3)}, %
  "h": \fpeval{round(\heighOfIdBox/\pttocm + 0.1, 3)}, %
  "p": \thepage%
  \}%
  )}%
}%
\global\booltrue{firstIdBoxDone}%
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% headers, footers

% Fix for resizing the header to match the whole size of the headers that differ on odd and even pages.
\makeatletter
\patchcmd\@outputpage{\headheight}{\ifodd\count\z@ 5cm\else 2.5cm\fi}{}{}
% Requires to adjust the footer position
\patchcmd\@outputpage{\global\@colht\textheight}{\global\advance\textheight by\ifodd\count\z@ 2.5cm\else -2.5cm\fi\global\@colht\textheight}{}{}
\makeatother
\lhead[\scalebox{5}{$\bullet$}]{\scalebox{5}{$\bullet$}}
\rhead[\scalebox{5}{$\bullet$}]{\scalebox{5}{$\bullet$}}
\chead[]{%
\begin{minipage}[t]{\textwidth}%
  \vspace*{0.1cm}\nameheader%
\end{minipage}%
}
\lfoot[\scalebox{5}{$\bullet$}]{\scalebox{5}{$\bullet$}}
\rfoot[\scalebox{5}{$\bullet$}]{\scalebox{5}{$\bullet$}}
\cfoot[\large\thepage~~/~~\pageref{LastPage}]{\large\thepage~~/~~\pageref{LastPage}}

\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question

\newcounter{Q}
\refstepcounter{Q}

% Temp counter used in answer box for questions
\newcounter{tempq}
% Temp counter used in answer box for exercises
\newcounter{tempe}
% Counter of multiple answer boxes for one question
\newcounter{subquestioncounter}
\setcounter{subquestioncounter}{1}
% Variable used to compute the height of answer boxes
\newlength{\heighOfBox}


\newcommand{\questionExam}[2][]{%
  % #1: optional label for the question
  % #2: the question text
  % Registering the label if provided
  \StrLen{#1}[\mystringlen]%
  \ifthenelse{\mystringlen > 0}{\label[question]{#1}}%
  % Writing the question text
  \smallskip%
  \noindent\textbf{Q.\arabic{Q}}\refstepcounter{Q}~#2%
  \medskip%
  \setcounter{subquestioncounter}{1} % reinit the local counter
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exercice

\newcounter{QE}
\stepcounter{QE}
\newcommand{\exerciceExam}[2]{%
  \StrLen{#2}[\mystringlen]%
  \ifthenelse{\mystringlen > 0}{\def\@temp{-- #2}}{\def\@temp{}}%
  \vspace{0.3cm}
  \section*{Exercice \arabic{QE} \@temp{} ($\approx$ #1 points)}
  \setcounter{tempe}{\arabic{QE}}%
  \stepcounter{QE}%
  \vspace{0.3cm}
  \setcounter{subquestioncounter}{1} % reinit the local counter
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QCM

\newcounter{qcmItems}
\newlength{\heighOfQCMBox}
\settototalheight{\heighOfBox}{\large $\square$}

\newlist{qcmExam}{enumerate}{1}
\setlist[qcmExam,1]{%
  label={\large $\square$ \protect\stepcounter{qcmItems}},
  %
  before={\protect\setcounter{qcmItems}{0}\protect\setcounter{tempq}{\arabic{Q}}\protect\addtocounter{tempq}{-1}\normalfont\zsavepos{answerbox\arabic{tempq}-\arabic{subquestioncounter}}},
  %
  after={%
  \zsavepos{answerbox\arabic{tempq}-\arabic{subquestioncounter}-b}%
  \pdfinfo{/correctexam-answer-\arabic{tempq}-\arabic{subquestioncounter}-\arabic{tempe} %
  (%
  \{ %
  "x": \fpeval{round(\zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
  "y": \fpeval{round(\the\paperheight/\pttocm-\zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm + (\zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}} - \zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}-b}) / \pxtocm + 0.2, 3)}, %
  "h": \fpeval{round((\zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}} - \zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}-b}) / \pxtocm, 3)}, %
  "w": \fpeval{round(\textwidth/\pttocm, 3)}, %
  "p": \thepage%
  \}%
  )}}
  % \pdfinfo{/correctexam-answer-\arabic{tempq}-\arabic{subquestioncounter}-\arabic{tempe} %
  % (%
  % \{ %
  % "x": \fpeval{round(\zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
  % "y": \fpeval{round(\the\paperheight/\pttocm-\zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
  % "h": \fpeval{round(\arabic{qcmItems}*((\itemsep+\parsep)/\pttocm+\heighOfBox/\pttocm), 3)}, %
  % "w": \fpeval{round(\textwidth/\pttocm, 3)}, %
  % "p": \thepage%
  % \}%
  % )}}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Answer zone (box)

% Boxing each column
\fboxsep=0pt

% The color of the line dots
\newcommand{\answerExamDotColor}{black}

% First argument: color (optional, by default black). The color of the dots. Put white for no dot.
% Second parameter: the line spacing
% Third argument: the number of lines
% Fourth argument: the number of columns
\newcommand{\answerExam}[4][black]{%
% Getting the count value of the current question
\setcounter{tempq}{\arabic{Q}}%
\addtocounter{tempq}{-1}%

% setting the dot color
\renewcommand{\answerExamDotColor}{#1}%
%
\global\boolfalse{firstColomnBoxDone}%
% Creating the required number of columns
\multido{}{#4}{%
% Computing the width of each column
\fpDiv{\answercolwidthExam}{1}{#4}%
%
% Simulation for getting the height of the box
\settototalheight{\heighOfBox}{\fbox{\parbox{\textwidth}{%
  \noindent\rule{0pt}{1.5\baselineskip}%
  \multido{}{#3}{\noindent\makebox[\linewidth]{\rule{0pt}{#2\baselineskip}\dotfill}\endgraf}%
}}}%
%
% One minipage for each column
\noindent\begin{minipage}[t]{\answercolwidthExam\textwidth}%
% Required to get the correct page:
\label{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
%
\noindent\ifbool{firstColomnBoxDone}{}{\zsavepos{answerbox\arabic{tempq}-\arabic{subquestioncounter}}}\fbox{\sbox{0}{\parbox{\textwidth}{%
  % Setting the seelcted color
  \color{\answerExamDotColor}%
  % Provides a larger gap between the preceding paragraph and the dots
  \noindent\rule{0pt}{1.5\baselineskip}%
  % Producing a dotted line
  \multido{}{#3}{\noindent\makebox[\linewidth]{\rule{0pt}{#2\baselineskip}\dotfill}\endgraf}%
  }}%
  \dp0=\dimexpr\dp0 + 10pt\relax
  \usebox{0}%
  }%
  %
  \ifbool{firstColomnBoxDone}{}{%
  % \begin{tikzpicture}[overlay]%
  % \draw[red] (\fpeval{round(- \the\textwidth/\pttocm * \answercolwidthExam + \evensidemargin/\pttocm + \zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm)}cm,  \fpeval{round(- \heighOfBox/\pttocm - \baselineskip/\pttocm, 3) / 2}cm) rectangle ++(\fpeval{round(\textwidth*#4/\pttocm, 3)}cm, \fpeval{round(\heighOfBox/\pttocm + \baselineskip/\pttocm, 3)}cm);
  % \end{tikzpicture}%
    %% Adding metadata of the answer box
    \pdfinfo{%
    /correctexam-answer-\arabic{tempq}-\arabic{subquestioncounter}-\arabic{tempe} %
    (%
    \{ %
    "x": \fpeval{round(\zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
    "y": \fpeval{round(\the\paperheight/\pttocm - \zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm  + (\heighOfBox/\pttocm + \baselineskip/\pttocm)/2, 3)}, %
    "w": \fpeval{round(\textwidth*#4/\pttocm, 3)}, %
    "h": \fpeval{round(\heighOfBox/\pttocm + \baselineskip/\pttocm, 3)}, %
    "p": \getpagerefnumber{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
    \}%
    )}%
  } % ifbool
\end{minipage}%
\global\booltrue{firstColomnBoxDone}%
}
  \global\boolfalse{firstColomnBoxDone}
  % Gap between dots and next paragraph
  \bigskip
  % Setting back the default dot color
  \renewcommand{\answerExamDotColor}{black}
  % Incrementing the counter of answer boxes per question
  \addtocounter{subquestioncounter}{1}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Answer zone with content (picture, etc.)


% First argument: the content of the zone. This content is used to compute
% the surrounding box.
\newcommand{\answerExamContent}[1]{%
% Getting the count value of the current question
\setcounter{tempq}{\arabic{Q}}%
\addtocounter{tempq}{-1}%
% Simulation for getting the height of the box
\settototalheight{\heighOfBox}{\fbox{\parbox{\textwidth}{%
  \noindent\rule{0pt}{1.5\baselineskip}%
  #1%
}}}%
%
\noindent\begin{minipage}[t]{\textwidth}%
% Required to get the correct page:
\label{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
%
\noindent\zsavepos{answerbox\arabic{tempq}-\arabic{subquestioncounter}}\fbox{\sbox{0}{\parbox{\textwidth}{%
#1%
  }}%
  \dp0=\dimexpr\dp0 + 10pt\relax
  \usebox{0}%
  }%
  % Adding metadata of the answer box
  \pdfinfo{%
  /correctexam-answer-\arabic{tempq}-\arabic{subquestioncounter}-\arabic{tempe} %
  (%
  \{ %
  "x": \fpeval{round(\zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
  "y": \fpeval{round(\the\paperheight/\pttocm - \zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm  + (\heighOfBox/\pttocm + \baselineskip/\pttocm)/2, 3)}, %
  "w": \fpeval{round(\textwidth/\pttocm, 3)}, %
  "h": \fpeval{round(\heighOfBox/\pttocm + \baselineskip/\pttocm, 3)}, %
  "p": \getpagerefnumber{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
  \}%
  )}%
\end{minipage}%
  \bigskip
  % Incrementing the counter of answer boxes per question
  \addtocounter{subquestioncounter}{1}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inline text box

\newlength{\widthOfInlineAnswerBox}
\newlength{\heightOfInlineAnswerBox}

\newcommand{\inlineAnswerBox}[1][10]{%
% Getting the count value of the current question
\setcounter{tempq}{\arabic{Q}}%
\addtocounter{tempq}{-1}%
%
\fpSub{\spacestoinclude}{#1}{1}%
%% Computing the dimensions of ID boxes
\settototalheight{\heightOfInlineAnswerBox}{\fcolorbox{gray}{white}{\strut\multido{}{\spacestoinclude}{~}}}%
\settowidth{\widthOfInlineAnswerBox}{\fcolorbox{gray}{white}{\strut\multido{}{\spacestoinclude}{~}}}%
%
% Required to get the correct page:
\label{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
%
\zsavepos{answerbox\arabic{tempq}-\arabic{subquestioncounter}}\fcolorbox{gray}{white}{\strut\multido{}{\spacestoinclude}{~}}%
% \begin{tikzpicture}[overlay]%
%   \draw[red] (\fpeval{round(-\widthOfInlineAnswerBox/\pttocm, 3)}cm,  \fpeval{round(- \heightOfInlineAnswerBox/\pttocm, 3) / 2}cm) rectangle ++(\fpeval{round(\widthOfInlineAnswerBox/\pttocm, 3)}cm, \fpeval{round(\heightOfInlineAnswerBox/\pttocm, 3)}cm);
% \end{tikzpicture}%
%% Saving pdf info
\pdfinfo{%
/correctexam-answer-\arabic{tempq}-\arabic{subquestioncounter}-\arabic{tempe} %
(%
\{ %
  "x": \fpeval{round(\zposx{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm, 3)}, %
  "y": \fpeval{round(\the\paperheight/\pttocm-\zposy{answerbox\arabic{tempq}-\arabic{subquestioncounter}}/\pxtocm + 0.33, 3)}, %
  "w": \fpeval{round(\widthOfInlineAnswerBox/\pttocm, 3)}, %
  "h": \fpeval{round(\heightOfInlineAnswerBox/\pttocm, 3)}, %
  "p": \getpagerefnumber{correctexam-\arabic{tempq}-\arabic{subquestioncounter}}%
\}%
)}%
%% Incrementing the sub question counter
\addtocounter{subquestioncounter}{1}%
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixing widow

\clubpenalty=10000
\widowpenalty=10000
\tolerance=1000

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supporting question labeling

\crefname{question}{question}{questions}
\crefalias{Q}{question}

\endinput
