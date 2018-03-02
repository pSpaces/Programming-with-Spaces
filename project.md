# Project management plan

## Objectives

The following table lists the main objectives of the pSpace project order by their urgency.

| Objective | Priority | Effort | Status | 
| - | - | - | - | 
| Reliability | high | medium | ✘ | 
| Maintainability |  medium | low | ✘ |
| Interoperability | high | medium/high | ✘ |
| Security | medium/high | medium | ✘ |
| Performance | low/medium  | high | ✘ |
| Enhancements | low | high | ✘ |

* Urgency: what needs to be addressed first.
* Objective: a desired property/capability of pSpaces.
* Priority: how important the objective is.
* Effort: predicted effort as the project grows, that is, how the effort required to maintain the objective grows as new features keep being added. 
* Status: ✓ (achieved), ✘ (non achieved).

The objectives shall act as barriers for all libraries: only once all libraries have meet the objective, development of the project can move to the next objective. 

## Tasks

We list here some tasks that need to be carried out to achieve the desired goals:

Reliability
* Networked repositories architecture (at least for one language)
* Well-defined protocol (at least for one language)
* End-to-end testing
* Unit testing

Maintainability
* Slim documentation 
* Commenting conventions
* Contribution rules

Interoperability
* Networked repositories architecture (for all languages)
* Protocol adherence for all languages

Security
* Access control
* Secure communication 

Performance
* Efficient data structures
* Benchmarking

Enhancements
* Persistency 
* Transactions 
* Mobility

## Responsibilities

The following table can be used to identify contact persons for each task/language:

| Objective | Networked Repository (C#/Java/Go?) | C# | Java | Go | Swift | TypeScript
| - | - | - | - |  - | - | - | 
| End-to-end testing | | | | | | |
| Unit testing | | | | | | |
| Slim documentation | | | | | | |
| Commenting conventions | | | | | | |
| Contribution Rules | | | | [Linas](https://github.com/luhac) | | |
| Networked repositories architecture | [Alberto](https://github.com/albertolluch)/[Thomas](https://github.com/Thomas58)/[Linas](https://github.com/luhac) | | | | | |
| Protocol | [Alberto](https://github.com/albertolluch)/[Thomas](https://github.com/Thomas58)/[Linas](https://github.com/luhac) | | | | | |
| Access control | | | | | | |
| Secure communications | | | | | | |
| Efficient data structures | | | | | | |
| Benchmarking | | | | | | |
| Persistency | | | | | | |
| Transactions | | | | | | |
| Mobility | | | | | | |
