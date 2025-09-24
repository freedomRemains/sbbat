package com.sb.sbbat.config;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

import com.sb.sbbat.tasklet.TaskletA;
import com.sb.sbbat.tasklet.TaskletB;

@Configuration
@EnableBatchProcessing
public class RunnerConfig {

    @Bean
    public Step stepA(JobRepository jobRepository, PlatformTransactionManager txManager, TaskletA taskletA) {
        return new StepBuilder("stepA", jobRepository).tasklet(taskletA, txManager).build();    }

    @Bean
    public Job jobA(JobRepository jobRepository, Step stepA) {
        return new JobBuilder("jobA", jobRepository).start(stepA).build();
    }

    @Bean
    public Step stepB(JobRepository jobRepository, PlatformTransactionManager txManager, TaskletB taskletB) {
        return new StepBuilder("stepB", jobRepository).tasklet(taskletB, txManager).build();
    }

    @Bean
    public Job jobB(JobRepository jobRepository, Step stepB) {
        return new JobBuilder("jobB", jobRepository).start(stepB).build();
    }

    @Bean
    public CommandLineRunner run(JobLauncher jobLauncher, Job jobA, Job jobB) {

        return args -> {
            String jobName = (args.length > 0) ? args[0] : "jobA"; // 引数指定がなかった場合のデフォルトジョブ
            Job jobToRun = jobA; // デフォルトジョブをjobAに設定
            if ("jobA".equals(jobName)) {
                jobToRun = jobA;
            } else if ("jobB".equals(jobName)) {
                jobToRun = jobB;
            }
            if (jobToRun == null) {
                throw new IllegalArgumentException("No job found with name: " + jobName);
            }
            JobParameters params = new JobParametersBuilder()
                    .addLong("time", System.currentTimeMillis())
                    .toJobParameters();
            jobLauncher.run(jobToRun, params);
        };
    }
}
