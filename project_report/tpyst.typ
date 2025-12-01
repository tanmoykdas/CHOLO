#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
  columns: 1,
)
// #set text(font: "Ubuntu Nerd Font")
#set text(size: 12pt)
#set par(justify: true)
#set heading(numbering: "1.")
#show bibliography: set heading(numbering: "1.")

// --------------------------
// Title page
// --------------------------

#set page(numbering: none)

#align(left)[
  #image("PSTU.png", width: 20%, height: auto, alt: "PSTU")
  #text(16pt)[
    *Patuakhali Science and Technology University* \
  ]
  #text(14pt)[
    Faculty of Computer Science and Engineering
  ]

  #line(length: 100%)
  #align(left, text(18pt)[
    *CCE 310 :: Software Development Project-I*
  ])
  #align(left, text(14pt)[
    *Sessional Project Proposal*
  ])
  #line(length: 100%)
]

#align(left)[
  #v(12pt)
  #image("logo.png", width: 45%, height: auto, alt: "Divider")
]

#align(bottom)[
  #line(length: 100%)
  *Project Title : CHOLO - University Student Ride Sharing Platform* \
  Submission Date : Mon 15, Sep 2025 \
  #line(length: 100%)
]

#align(top)[
  #table(
    columns: (35%, auto),
    [
      #text(size: 14pt)[
        *Submitted from,* \
      ]

      *Md. Sharafat Karim* \
      *ID* : 2102024, \
      *Reg* : 10151, \
      *Semester* : 5 \ (Level-3, Semester-1)
    ],
    [
      #text(size: 14pt)[
        *Submitted to,* \
      ]
      #parbreak()
      + *Prof. Dr. Md Samsuzzaman* \
        Professor, \
        Department of Computer and Communication Engineering, \
        Patuakhali Science and Technology University.
      + *Arpita Howlader* \
        Assistant Professor, \
        Department of Computer and Communication Engineering, \
        Patuakhali Science and Technology University.
    ],
  )
]


#pagebreak()
#set page(numbering: "1")
#outline()
#pagebreak()

// --------------------------
// Contents
// --------------------------


#align(center)[
  #image("logo.png", width: 15%, height: auto, alt: "PSTU Diary Logo")
]
#align(center)[
  #text(size: 20pt, weight: "bold")[PSTU Diary]
]

= Introduction

CHOLO (meaning "Let's Go" in Bengali) is a specialized ride sharing mobile application designed exclusively for students of University. The platform addresses critical challenges university students face including limited financial resources, safety concerns, and unreliable transportation options.

Unlike conventional ride sharing services, CHOLO creates a trusted network by restricting access to verified university students only through institutional email authentication. The application leverages Flutter for cross platform development, Firebase for backend services and Google Maps API for location based features. The platform operates on a peer-to-peer model where students can either offer rides or book rides from fellow students, featuring real time location tracking, two way rating system and secure authentication.

= Objectives

The development of CHOLO is guided by university student transportation needs:

- To implement a platform exclusively for verified university students using institutional email authentication, ensuring a trusted community environment.

- To enable students to share ride expenses through a collaborative economy model, targeting 40-60% cost reduction compared to commercial ride sharing services.

- To integrate Google Maps API for accurate location selection, geocoding, and navigation, ensuring seamless ride coordination.

- To develop a two way rating mechanism promoting accountability and safety between drivers and passengers, fostering trust within the community.

- To provide students with capabilities to offer rides, book rides, view ride history, and manage bookings efficiently through a centralized platform.

- To ensure platform security through a dual email verification system (personal + university email), guaranteeing only verified students access the platform.

- To ensure the application works seamlessly on both Android and iOS platforms with consistent user experience across devices.

- To implement Firebase security rules, HTTPS encryption, and secure data handling protocols protecting all user information.

= Problem Statement

University students face critical transportation challenges that existing solutions fail to address. Commercial ride sharing apps like Uber and Pathao are financially unaffordable for students on limited budgets, with daily costs accumulating to substantial monthly expenses. Safety concerns are equally significant, as students require a trusted network with verified identities rather than unknown commercial drivers, especially during late night travel.

Existing platforms lack university specific features such as campus routes, synchronized class schedules, and community based verification. Students currently rely on inefficient informal arrangements through social media groups, which lack proper structure, accountability, and safety mechanisms. This creates a need for a dedicated platform designed specifically for verified university students with built-in trust and security.

= Related Work


Uber @uber2024 is a global ride sharing platform that revolutionized urban transportation with professional drivers, real-time GPS tracking, and comprehensive safety features. The platform offers seamless booking, cashless payments, and dynamic pricing based on demand. However, Uber's business model targets occasional riders rather than daily commuters, making it financially unsustainable for students. The surge pricing during peak hours—when students most need transportation often doubles or triples fares. Additionally, Uber lacks student verification systems, university specific route optimization, and community based features that would address campus transportation needs.

Pathao @pathao2024, popular in Bangladesh and South Asia, provides similar ride sharing services with additional features like motorcycle rides for more affordable options. While Pathao's pricing is generally lower than Uber, it still operates on a commercial model with surge pricing during high demand periods. The platform focuses on urban commuting for general users without considering the unique patterns of university life such as synchronized class schedules, campus routes, or student budget constraints. 

Both platforms lack the trusted community verification that students need, relying instead on anonymous commercial drivers. CHOLO addresses these limitations by creating a student-only network with university email authentication, enabling peer-to-peer carpooling at significantly reduced costs while maintaining safety through community trust.

= Scope

The CHOLO platform provides comprehensive ride sharing capabilities exclusively for university students. Core features include dual email verification for secure authentication, ride creation and booking with Google Maps integration for location selection, and a two way rating system for accountability. The platform offers profile management, ride history tracking, and real time Firebase synchronization for instant updates. Built with Flutter, the application features a modern UI with glassmorphism effects and is fully functional on Android with iOS deployment ready.


= Methodology

== Technology Stack

The development of CHOLO follows modern best practices with a robust technology stack:

- *Frontend*: Flutter 3.38.1 
- *Backend Services*: Firebase Authentication, Cloud Firestore, Firebase Storage
- *UI Design*: Material Design 3 with custom glassmorphism effects
- *Database*: Cloud Firestore (NoSQL real time database)
- *Authentication*: Firebase Auth with dual email verification
- *Location Services*: Google Maps API, Geolocator, Geocoding
- *Additional Tools*: Image Picker, HTTP, Shared Preference
- *Notifications*: Firebase Cloud Messaging (FCM)

== Design Principles

The design of CHOLO adheres to the following principles:

- *Material Design 3*: Following Google's latest Material Design guidelines for consistent and modern UI/UX with dynamic color theming and adaptive layouts.
- *User-Centric Design*: Focusing on student needs with intuitive navigation, clear visual hierarchy, and minimal learning curve for seamless user experience.
- *Safety First*: Dual email verification, rating system, and student-only network ensuring trusted community and secure interactions.
- *Real-Time Updates*: Leveraging Firebase real-time capabilities for instant ride updates, booking notifications, and seamless data synchronization.
- *Cross-Platform Consistency*: Ensuring identical functionality and design across Android and iOS platforms for uniform user experience.
- *Security*: Firebase Authentication, Firestore security rules, HTTPS encryption, and secure data handling to protect user information.
- *Performance*: Optimized image loading, efficient state management, and smooth animations for responsive and fluid user experience.

= Visual Models

== Flow Chart Diagram

#figure(
  image("flowchart.png", width: 65%, height: auto, alt: "Flow Chart"),
  caption: "Flow Chart of CHOLO",
) <DFD>

The above @DFD illustrates the overall architecture of the CHOLO, showing the interaction between users, the frontend application, backend services, and the database. It highlights the flow of data and the key components involved in the system.

== Schema Diagram

#figure(
  image("scema.png", width: 100%, height: auto, alt: "Database Schema Diagram"),
  caption: "Database Schema Diagram of CHOLO",
) <Schema>

The above @Schema illustrates the database schema for CHOLO, showing the tables, their fields, and relationships between them. The schema is designed to efficiently store and retrieve contact information and user data.


== ERD (Entry Relationship Diagram)

#figure(
  image("er.png", width: 75%, height: auto, alt: "Entity Relationship Diagram"),
  caption: "Entity Relationship Diagram of CHOLO",
) <ERD>

The above @ERD illustrates the entity-relationship diagram for CHOLO, showing the entities, their attributes, and relationships between them. The ERD helps in understanding the data model and how different entities interact with each other.


== Timeline (Gantt Chart)

The base timeline for the development of PSTU Diary is as follows,

#figure(
  table(
    columns: (auto, 7.5%, 7.5%, 7.5%, 7.5%, 7.5%, 7.5%, 7.5%, 7.5%),
    [*Task*], [*Week 1-2*], [*Week 3-4*], [*Week 5-6*], [*Week 7-8*], [*Week 9*], [*Week 10*], [*Week 11*], [*Week 12*],
    [Requirements & UI Mockup], [✓], [], [✓], [], [], [], [], [],
    [App structure and navigation design], [], [✓], [✓], [], [], [], [], [],
    [Basic UI and supabase/ backend integration], [], [], [✓], [✓], [], [], [], [],
    [Admin panel design with role-based access control], [], [], [✓], [✓], [✓], [], [], [],
    [Fetch data realtime from db], [], [], [], [], [], [✓], [], [],
    [UI Polish & Documentation], [], [], [], [], [], [✓], [✓], [],
    [Final Testing & Deployment], [], [], [], [], [], [], [], [✓],
  ),
  caption: "Development Timeline of CHOLO",
)

The timeline is divided into 12 weeks, with specific tasks allocated to each period which describes an approximate timeline for the whole development process.

== UI Mockups

// #figure(
//   image("UI/1.png", height: 50%, alt: "UI Mockups"),
//   caption: "UI Mockups of PSTU Diary",
// ) <UI1>

#figure(
  grid(
    columns: (auto, auto),
    rows: (auto, auto),
    gutter: 1em,
    [ #image("1.jpg", width: 61%) ], [ #image("2.jpg", width: 61%) ],
  ),
  caption: [Add Lounch page and Homepage],
) <UI2>

#figure(
  grid(
    columns: (auto, auto),
    rows: (auto, auto),
    [ #image("3.jpg", width: 61%) ], [ #image("4.jpg", width: 61%) ],
  ),
  caption: [Profile and account creation],
) <UI3>

= Future Plans

- Develop in app messaging for direct communication between drivers and passengers.
- Integrate mobile payment solutions (bKash, Nagad) for seamless cashless transactions.
- Enhance rating system with category based feedback. 
- Deploy AI powered ride matching algorithm based on routes and schedules
- Implement emergency SOS button with automatic location sharing to emergency contacts.
-  Enable ride history export and automated receipt generation.
- Expand platform to multiple universities across Bangladesh..
- Establish vehicle verification system with document and photo verification.

= Result

CHOLO has successfully achieved its core objectives as a university student ride-sharing platform. The application is fully functional on Android with all essential features implemented and tested. User registration operates smoothly with dual email verification ensuring only verified university students access the platform. The authentication system securely manages user sessions while profile management allows students to upload photos and maintain their information.

#bibliography(title: "References", "refs.bib")

#align(center + bottom)[
  *THE END*
]
