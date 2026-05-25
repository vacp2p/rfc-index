# ANALYSIS-ANONYMITY

| Field | Value |
| --- | --- |
| Name | [Analysis] Anonymity |
| Slug | 183 |
| Status | raw |
| Category | Informational |
| Editor |  |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-anonymity.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-anonymity.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

### Summary of “[Are continuous stop-and-go mixnets provably secure](https://eprint.iacr.org/2023/1311)?” article.

- Adversary: We consider a probabilistic polynomial time (PPT) adversary that can observe (but not alter) all network traffic. The adversary can also perform passive and static corruptions of senders, the recipient R, and a subset of mixnodes. Passive and static corruption means that the adversary chooses the subset of corrupted parties before the protocol starts; the adversary then has access to the internal states of these c mixnodes, including all of their keys and random choices; however, the compromised parties still follow the protocol specifications.
- User Unlinkability: In our first definition, the adversary does not control the time when the challenge messages are released, and the content of any other messages from the honest users. This more closely captures the surveil- lance scenario where the adversary observes an interesting/disturbing message received by the recipient and then tries to figure out who among Alice and Bob could have sent that message. Informally, the protocol achieves anonymity according to this definition as long as a target message from Alice is ‘mixed’ with at least one message from Bob.
- Pairwise Unlinkability: Our second definition is stronger; here, we consider that the adversary controls the time when the challenge messages are released to the challenge users, the content of all other messages from the honest users, and then tries to distinguish who among them have sent which of the challenge messages after they are received by the recipient. Such a definition is useful to capture a strong adversarial scenario in the context of whistleblowing where the adversary might release fake/tagged documents and observe the time of its release to identify the whistleblower.
    - In one of our main results, we prove that in continuous mixnets, by controlling the time of release, the adversary can exploit the fact that whichever message goes into the AC network first, comes out first with good probability - which we formally denote as the FIFO attack.
- The cascade continuous mixing (CCM) protocol: i) Each message travels through a fixed cascade of k hops before getting delivered to the recipient; ii) The sender then onion encrypts the message (using Sphinx packet structure) for the cascade (including the recipient), and sends it to the first of the mixnode in the cascade after some delay sampled from exponential distribution; iii) Each mixnode delays the messages also following an exponential distribution.
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXeEv6p1o-P1Fk8fYjnZCeoZ6mQqUa6RCDzbkDt32QCdgIkd62LjTzFdraWuE5Cnnnl44V0LrQ8h7-lpKjDUUbjrWUDvml1GGG0yeTvYA1HNw6RxTQ5UJyZbykpVCKtjcLZwvJu5gA75vwaDl6yYk_tEj5zw?key=SwbMSSilnhvHe1V0xsYGLQ)
- The multi-path continuous mixing (MCM) protocol: i) We consider a stratified topology where mixnodes are arranged in a number of layers, such that mixnodes in layer i receives messages from mixnodes in layer i - 1 and sends messages to mixnodes in layer i+1. The path length of message routes is determined by the number of layers, and is denoted by k. Further, we consider that each layer has exactly K mixnodes; ii) The sender of the message picks a path of length k by picking one mixnode uniformly at random from each layer, independent of the choices of other users or other messages; iii) The sender samples k independent delay values from exp. distribution. They then onion-encrypt the message for the path (including the recipient), and embed the values in the onions header such that only i-th mixnode can see its delay value. Then they send it to the first of the mixnodes in the path after a delay sampled from the exp. distr.
- A trusted third party (TTP) anonymizer receives messages and shuffles them. If there are a sufficient number of messages received by the TTP regularly, then each message will mix with enough number of other messages. However, if a set messages are received by the TTP exactly at the same moment, their output order will not reveal anything to the adversary; and we could say that those messages are “shuffled” with each other.
    - TTP interacts with the senders in U and the recipient R, and is parameterized by latency k and delay λ. The senders provide TTP with their messages over a secure channel, so that no information about the message content is leaked to the adversary.
        ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXeCFapqD4njwjC32O8hm0rw2WIAS9FrASc2zyqGE_Ur8T7RJHu7hubQJtVHKjCFXD8yQP4ysWpbpvxA-ucGBzeQZgPQ_4rq0R9zSOrEfARVeyZxIKuxwb0iQKliiYT3cm4Vxrnv_JQfFBuVdRvp7_NcME6t?key=SwbMSSilnhvHe1V0xsYGLQ)
    - TTP acts as a central mixing node that delivers the messages to R after adding a delay (sampled from some prob. distribution related to the protocol).
    - Assuming that the central mixing node is honest, the power of the adversary is limited to an observer that monitors incoming and outgoing traffic.
    - As this sets the minimum power for a global passive adversary, the security of TTP serves as an optimistic bound of the security expected by a typical mixing construction.
- FIFO attack
    - We consider a simplified setting with (i) two senders u0, u1; (ii) a single recipient R; and (iii) TTP. The system state is as follows: each sender has a single message in her buffer and the queue is empty, i.e. there are no prior pending messages. The senders u0 and u1 send their messages to the recipient R that receives the messages m0 and m1.
        ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXe-4ImhIeqo9OSTuiArlrWBVmyWrKmfahNejJ4qJ71C8RK1LWRb9DvDe5Vpmik7vtNVa1wTkduhaYkfMkp_3OLHm6cjd3XWc-FXbdcaxAPbVLzSPhqTafHTO8GNYXXZy9Kje5gsto_8LAGRTzXg9CYM0YyV?key=SwbMSSilnhvHe1V0xsYGLQ)
    - The goal of the mix is to provide sender anonymity against an adversary that controls R and is a global observer, i.e. to hide whether communication occurs in 1) a “direct” manner: i.e. the users u0 and u1 sent, respectively, the messages m0 and m1 to R or 2) a “cross” manner: i.e. the users u0 and u1 sent, respectively, the messages m1 and m0 to R.
    - The adversary begins observation at some given time when the messages m0 , m1 are in the sender’s queues and are about to be delivered. By the memoryless property (?) and the description of the system state, we may assume that observation begins at time 0. Then adversary executes the following steps:
        ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXctmeteVHv7igyqjuCORblp83P8p5g5rDASpBffu9WDaBpEQ0sU2rYYTdJyxTNohIbs1HWU0UuoZ9LpSVtM6t9Xj7U-ldWpDx3zW9MYf1AQ8lvurnClmpgQyfn-U8t2hVTC27rcZ2vryIq0EbjVIDu9n252?key=SwbMSSilnhvHe1V0xsYGLQ)
    - In a nutshell, adversary guesses based on the prediction that messages input earlier to the mixing node are more likely to be delivered earlier to the intended recipient.
- Analysis of the FIFO attack
    - Without loss of generality, assume that the users $u_0$ and $u_1$ provide the messages $m_0$ and $m_1$, respectively, in a “direct” manner to $R$ (due to symmetry and independence, the “cross” case can be analysed similarly?).
    - We denote the following random variables:
        1. The delay $x_0$ until $m_0$ is sent to TTP by $u_0$.
        1. The delay $x_1$ until $m_1$ is sent to TTP by $u_1$.
        1. The delay $y_0$ of TTP until $m_0$ is forwarded to $R$, i.e. the time $m_0$ stays in the TTP.
        1. The delay $y_1$ of the TTP until $m_1$ is forwarded to $R$, i.e. the time $m_1$ stays in the TTP
    - We have that $t_{s,0}$,$t_{s,1}$, $t_{r,0}$ and $t_{r,1}$ are the time values of $x_0$, $x_1$, $x_0$+$y_0$, $x_1 + y_1$, that adversary observes, in the direct case.
    - Thus adversary wins when either one of the following events happen:
        1. $E_{0<1}: x_0 < x_1$ and $x_0 + y_0 < x_1 + y_1$;
        1. or $E_{0\geq1}: x_0 \geq x_1$ and $x_0 +y_0 \geq x_1 +y_1$;
            ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXePQ5mTrLvedWLLwtOHP340bXRJmIavl3xg8AR-xJIu3ylt8jtyG3m9Vn0zUnO4pME_bxnzJyyGacQISwQMWJPOvk4zNy5247Bt04qmRk-g2OQfeh_z5v6wOqWihwpRUU0q0gloeMrkmruBHhhjNO-gBnu3?key=SwbMSSilnhvHe1V0xsYGLQ)
- User unlinkability definition
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcEAFplYjCMBQ1QKzbqz8KnZaPFsz7UVD35lvtPATWu_6NA5sjWIqMttobV1NPLVeg-nnRzS-1IT8yYOeW7vITLc7qLVIXb5Xy21ty0zS5gaQc6-9C0BpyTAfWPkY57XQwVR0zerbetsqC4Jp92P1jDGQGh?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F41367a55-f0b6-4bc1-bf86-eba88cb5cc4d%2FScreenshot_2024-08-10_at_19.50.13.png?table=block&id=1fd261aa-09df-81f9-a37e-e564487aa4de&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Analysis for User Unlinkability
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXfQQWM2scLwXsvofLFmp7pHSm7Qkenmgvubo003trKN_yhPPTGzSxNWIrbmhiv2awynsW7QLFw0YjZ1rzWaLNGx-BHL6zOKL2oqgkq0RRKgk3FE1znREODefKDuBr--Zdcipm8HFqi5pHxz1JcS3pCzg9pZ?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://lh7-us.googleusercontent.com/docsz/AD_4nXfHMhmuXc1ruUtJ-he8hs9mABuZvz-mfcmRmEbVG4oEoTHixCmOh8RWGH6Py8K6gIaPyZz8_TCFgMV-OTP4SIJXYcqEwy7PhJG-F4ZexB3jsZ0OxFtdQryH3xa7B-6b2r6syoC3-PpBp-f-uPClrTFCp662?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://lh7-us.googleusercontent.com/docsz/AD_4nXfYPTg2FLQJsiwKuoI18yyAfqCZir6GrSee9Al4oLz3cusZ5eyTjgwNiXd7kXf5WrDlrLbfqco5AvC_XTIsVjPdRUChfVJxUu48cVfxEIr_xcoYfAgDM4zy7IvpUZwtaGjilifzp01elgW976ApWcI4aIgU?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcsu4aA_UeFmr7Lo0JiKz_SmeKmQ6T2yKOG_z5u8l_s3VsBoj8oyOq_8SuZwWddRBR7HxQST7v21KKjEZjF6mMjaTX7mCXbkLxcPes-5xQBNQTynXvpesDHtMDNPoQbJrHKuOsPImThvizNcZrYkqVDlQs?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcfvPi-xKaduisFeBeD110O5dR_OSxtTqJ8tjULzl_5CZnKVRtqQzYRGx1zBHbNT_h6aj3iZ08sneoS5IkkCNAL3SF24VSTP2F6GYGQ2bI9MSa86nAnS8YJgx88EMGKGG5Yk9_pdyniaTZ9Q1ZmC6KrEUk?key=SwbMSSilnhvHe1V0xsYGLQ)

![](https://lh7-us.googleusercontent.com/docsz/AD_4nXd521fMQk_pPhrmArfgsYGpt8tQGKkEuxmPAJlm90QvjmSTVnujD1ZX9pSgdMZzBMVQZxQuySa4W5KlK95BHeIIed8O0maXXMAQCwi-v76CKjbs3-p0nkyvOROMXOMVw-_8d97HqliOAJbbu2PrEgJr_za7?key=SwbMSSilnhvHe1V0xsYGLQ)

- Pairwise Unlinkability definition
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXdYYpK5X3OgjdQZ_akxWXzzBcXEEpyyKEL7gnJ4CwNho8rPlR5Jk8MJYTTjLBMeKmsDmReERrMVQFVLUJ-AJksGNthGzSnIfFyXtjcCed85SqxJZV1dB4k31H3Ll0TnD1YX8ApDXLEL4dzPc6okbv-K2aMI?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXe_d78BNGXV9Z04L5kJd8Ux_SM-n3IUh1v4lcsG-90VStZrv1pp8hS7vbfQJaasLaMQmJO506_MbFphDK3S17ccUg5ZgC0fMop3PGUK7DnrL8iLopQ4ZeGOwy6RhAjTL7fcnXr9W30CPGFbFJMb4eCILU3n?key=SwbMSSilnhvHe1V0xsYGLQ)
- Analysis for Pairwise Unlinkability
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXeeB0nCkxi1UJ7Ycgbbm4Ww4sgAHIgGth1ixgsUFwiLEg4NwGi-lvhElDLrizOsQVoY9W2ICpIBcHWeP3YHQa5YEEKZuuYigpbpVlOuVP3z0aTs-NsWO0Ut2e95lfW3BiYGDIWk8kvFSIWlp3NBGe97HBdk?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXfzDzbZ5FGrHkXS_kxx0b1v-DnFzLncOwhWH19SHtVOn9GQxXdc1_1EA5jwgq9iX7u2ve9pXKOUFXZsXFGZZ99ItsKufKIbejKVZ3ejakNsvAOzng9q7PLCd0Ee3bKyUKzT7OrY5_iur5RhHKElnvaHaKo?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcwlE4zglXthNZ9VK0S5qCqwogNE9pcqCcnjtvlsVrMCweYJsK5xUKDLStCIuxkBafJuZRm_A9KWu_FAhr3tbF1MwHG44oJiigfqeoVvtdkPy2sUcgKKlO29VTyQ8Drmgins4_yBSQRKX-2qgL-qYUOGFzu?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcerIeAJFaJ0nFHvjOov77uC8IP6MjICFvbNi4bbmT0wjIQKnc_tSROpjL6wPTs4FRaU0qGug7a8d0b7p1c1UOa4sdmoTgMrVhghqHYDHf9IbQ7E5EV0TUfRT5V8VCWrjE3WeRSq9fWd4YNdQY9F0g1R7Df?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXeJnupyl4LMFwqb43xOQ3NUUyEUE_7ayU0nJPgJKYBFlmfAh7l4TT_UguxWnTs_tBDvfkU_F8Cj1OMC5CgcwbNxB91YPtbw4-QO_WMqawmU2MA4TY2cwTwJNvkcRBdPrTBqDXLbcIAKGFJkTCcgEI72iLQ?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXeNn3ZCwd_sSEmgcIAJTP7AwneNgEHnOnkxwkxXzeujqSsJ-7613U8I88F9s684CKvKRDDMKXcOCshJEyQEYqbH8BOyAPfeAyx9OyYdsnZWRoI0OEzy53TLAOHYrtaROlGq45Q47rbe9IUE-1toemHjk6E?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcz55oqo7WfYjfqmkFV8ldpxbNBvDPtzEUFCU5fye1-z8K4lShWf_R--M6yBYdQo7YRvuDdrVVYprGdc2McI52haW_HWUoZmuFyQTRIeMcezggqLfDxjx1lpsf1K-Xa55vBqsjg7eBmFw1mrOIpfmV7KJYg?key=SwbMSSilnhvHe1V0xsYGLQ)
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXfflzkZJAS_QJCIW0F2dfWhi2gjW1IJMocvKD0ZpBeSGvlLiGLtrEW0CqwKh3-dKtiDSejuT-tSsQj0xvwrpxoktvAa4syZFDXmFKmT-QQ4TLGjEhFzEalWYrBI67I-GSKnIDzF4WtTsiA307ZE2gSgpALK?key=SwbMSSilnhvHe1V0xsYGLQ)
- In above we plot the prob. bound from the inequality |prob. -1/2| \leq \delta . For example using Theorem 2 (plot (d) in the above) we obtain the following
    ![](https://lh7-us.googleusercontent.com/docsz/AD_4nXcyqtzrtcr77pzUvBzVX9rmF9DWhh_eNm45vPW82Zl8Nfnf8Nnu3JtIKhw2B9OMqIl_vnCUIDSmLmFiS0QgxxDFWO6rUuEtkImC4fAjwZ6MO2i1o-F1oOex2fLh5NQmYHywyJzMHHw-IudYek3pYla3GUVA?key=SwbMSSilnhvHe1V0xsYGLQ)

### Summary of “[The Generals' Scuttlebutt: Byzantine-Resilient Gossip Protocols](https://dl.acm.org/doi/abs/10.1145/3548606.3560638)”

- Abstract

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2d60f47d-5215-487f-961d-7a68f225637e%2FScreenshot_2024-07-05_at_16.40.07.png?table=block&id=1fd261aa-09df-81c1-acf2-e93f44a10e3b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F93d3a133-8c05-4646-a9ff-3cfc8bd5453a%2FScreenshot_2024-07-05_at_16.42.26.png?table=block&id=1fd261aa-09df-819e-80c7-e8480028047e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0c25fc2d-ea05-489c-ba3b-21be3cb295cd%2FScreenshot_2024-07-05_at_16.43.32.png?table=block&id=1fd261aa-09df-8111-9104-c772f683aeb9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
